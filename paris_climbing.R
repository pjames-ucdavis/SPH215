#############################################################################
#                  OSRM TRAVEL-TIME CALCULATION WITH R                      #
#  APPLICATION TO ARTIFICIAL CLIMBING WALLS IN PARIS AND ITS NEIGHBOURHOOD  #
#                        R. YSEBAERT, JUNE 2022                             #
#############################################################################

# Sources files (in data-raw folder, not included in the github repo)
# IRIS géométries (édition 2020) : https://geoservices.ign.fr/contoursiris
# IRIS income : https://www.insee.fr/fr/statistiques/6049648
# IRIS population : https://www.insee.fr/fr/statistiques/5650720?sommaire=4658626 

# Documented script (Quarto Notebook) : https://rysebaert.github.io/climbing_paris/


# 1. Map layout preparation at IRIS scale (source IGN)----
library(sf)
iris <- st_read("/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/CONTOURS-IRIS_2-1__SHP__FRA_2020-01-01/CONTOURS-IRIS/1_DONNEES_LIVRAISON_2020-12-00282/CONTOURS-IRIS_2-1_SHP_LAMB93_FXX-2020/CONTOURS-IRIS.shp", quiet = TRUE)

# Extract Paris and delete 
# Bois-de-Vincennes / Boulogne Iris for map template
iris$dep <- substr(iris$INSEE_COM, 1, 2)
paris <- iris[iris$dep == "75",]
paris <- paris[!paris$NOM_IRIS %in% c("Bois de Vincennes 1",
                                      "Bois de Vincennes 2",
                                      "Bois de Boulogne 1",
                                      "Bois de Boulogne 2",
                                      "Bois de Boulogne 3"),]
paris <- st_union(paris)

# 5 km around Paris map layout
paris5k <- st_buffer(paris, 5000)
paris5k <- st_as_sfc(st_bbox(paris5k, crs = 2154))
paris <- paris5k

# 10 km around Paris (get OSM data) in long/lat
paris10k <- st_buffer(paris, 10000)
paris10k <- st_as_sfc(st_bbox(paris10k, crs = 2154))

# Intersection with IRIS
iris10k <- st_intersection(iris, paris10k)

# Bounding box for osm extraxt
paris10k <- st_transform(paris10k, 4326)
paris10k <- st_bbox(paris10k) 
paris10k <- as.vector(paris10k)


# 2. Feed IRIS layer by socio-economic data (INSEE) ----
library(readxl)
df <- read_xlsx("/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/base-ic-evol-struct-pop-2018.xlsx", skip = 5, sheet = "IRIS")
iris10k <- merge(iris10k[,c("CODE_IRIS", "NOM_IRIS", "TYP_IRIS", "NOM_COM")], 
                 df[,c("IRIS","P18_POP")],
                 by.x = "CODE_IRIS", by.y = "IRIS", all.x = TRUE)

#df <- read_xlsx("data-raw/BASE_TD_FILO_DISP_IRIS_2019.xlsx", skip = 5, sheet = "IRIS_DISP")
#iris10k <- merge(iris10k, df[,c("IRIS","DISP_MED19")],
#                 by.x = "CODE_IRIS", by.y = "IRIS", all.x = TRUE)

iris <- st_intersection(iris10k, paris5k)

# Keep only habitation IRIS for origins calculation
ori <- iris10k[iris10k$TYP_IRIS == "H",]
ori <- st_centroid(ori)

# Transofrm in long/lat
ori <- st_transform(ori, crs = 4326)
iris <- st_transform(iris, crs = 4326)


# 3. Extract OSM objects (climbing and map layout)----
library(osmdata)

# define a bounding box
q0 <- opq(bbox = paris10k) 

# extract climbing areas
q <- add_osm_feature(opq = q0, key = 'sport', value = "climbing")
res <- osmdata_sf(q)
dest <- res$osm_points
dest[,"name"] <- iconv(dest$name, from = "UTF-8", to = "UTF-8")


# Cleaning
private <- dest[!is.na(dest$brand),] # Manage private and associative areas
asso <- dest[!is.na(dest$federation),]
asso$type <- "Associative structure"
private$type <- "Speculative structure"
dest <- rbind(asso, private)
dest$federation[is.na(dest$federation)] <- "Private"
# Find walls and boulders
dest[c("climbing.toprope", "climbing.boulder")][is.na(dest[c("climbing.toprope", "climbing.boulder")])] <- "no"
dest$climbing_type <- ifelse(dest$climbing.toprope == 'yes' & 
                               dest$climbing.boulder == "yes", 'Wall and bouldering',
                             ifelse(dest$climbing.toprope == 'yes' & 
                                      dest$climbing.boulder == "no" , 'Wall',
                                    ifelse(dest$climbing.toprope == 'no' & 
                                             dest$climbing.boulder == "yes" ,
                                           'Bouldering', NA)))
# Keep only attributes of interest and rename it
cols <- c("osm_id", "name", "climbing_type", "climbing.length",
          "climbing.routes", "type", "federation", "brand")
dest <- dest[,cols]
colnames(dest)[4:5] <- c("climbing_length", "climbing_routes")

# Intersection with bouding box 
poi <- st_transform(dest, 2154)
poi <- st_intersection(poi, paris5k)
poi <- st_transform(poi, 4326)




# 4. Origin - Destination calculation with OSRM ----
library(osrm)

## 4.1 IRIS to climbing areas----
# Manage ids
row.names(ori) <- ori$CODE_IRIS

# Connexion to osrm local server (the osrm container must running under docker)
options(osrm.server = "http://localhost:5000/", osrm.profile = "bike")

# Origin-destination calculation
# All structures
df <- osrmTable(src = ori, dst = dest, measure = "duration")
df <- data.frame(df$duration)
colnames(df) <- as.character(dest$osm_id)
row.names(df) <- as.character(ori$CODE_IRIS)
write.csv(df, "data-conso/bike-duration.csv")

# Private structures
dest_priv <- dest[dest$type == "Speculative structure",] 
df2 <- osrmTable(src = ori, dst = dest_priv, measure = "duration")
df2 <- data.frame(df2$duration)
colnames(df2) <- as.character(dest_priv$osm_id)
row.names(df2) <- as.character(ori$CODE_IRIS)
write.csv(df2, "data-conso/bike-duration-priv.csv")

# FFME
dest_asso <-dest[dest$type == "Associative structure",] 
dest_ffme <- dest_asso[dest_asso$federation == "FFME",]
df3 <- osrmTable(src = ori, dst = dest_ffme, measure = "duration")
df3 <- data.frame(df3$duration)
colnames(df3) <- as.character(dest_ffme$osm_id)
row.names(df3) <- as.character(ori$CODE_IRIS)
write.csv(df3, "data-conso/bike-duration-ffme.csv")

# FSGT
dest_fsgt <- dest_asso[dest_asso$federation == "FSGT",]
df4 <- osrmTable(src = ori, dst = dest_fsgt, measure = "duration")
df4 <- data.frame(df4$duration)
colnames(df4) <- as.character(dest_fsgt$osm_id)
row.names(df4) <- as.character(ori$CODE_IRIS)
write.csv(df4, "data-conso/bike-duration-fsgt.csv")


## 4.2 Isochrones from a regular grid to climbing areas ----
# Compute travel time from grid to climbing areas
# Create grid and extract centroids (cell size = 150 m)
mygrid <- st_make_grid(paris5k, cellsize = 150)
mygrid <- st_centroid(mygrid)
mygrid <- st_sf(ID = 1:length(mygrid), geometry = mygrid)

dest <- st_transform(dest, 2154)
dest_priv <- dest[dest$type == "Speculative structure",] 
dest_fsgt <- dest[dest$federation == "FSGT",]

# Compute travel time from grid centroids to all climbing areas
df5 <- osrmTable(src = mygrid, dst = dest, measure = "duration")
df5 <- data.frame(df5$duration)
write.csv(df5, "data-conso/grid-bike-duration.csv", row.names = FALSE)
df5 <- read.csv("data-conso/grid-bike-duration.csv")
colnames(df5) <- as.character(dest$osm_id)
time <- data.frame(mygrid$ID, apply(df5, 1, min)) # find minimum value
colnames(time) <- c("ID", "TIME_ALL")
mygrid <- merge(mygrid, time, by = "ID", all.x = TRUE) # merge time to grid

# Compute travel time from grid centroids to private climbing areas
df6 <- osrmTable(src = mygrid, dst = dest_priv, measure = "duration")
df6 <- data.frame(df6$duration)
write.csv(df6, "data-conso/grid-bike-duration_priv.csv", row.names = FALSE)
df6 <- read.csv("data-conso/grid-bike-duration_priv.csv")
colnames(df6) <- as.character(dest_priv$osm_id)
time <- data.frame(mygrid$ID, apply(df6, 1, min)) # find minimum value
colnames(time) <- c("ID", "TIME_PRIV")
mygrid <- merge(mygrid, time, by = "ID", all.x = TRUE) # merge time to grid

# Compute travel time from grid centroids to FSGT climbing areas
df7 <- osrmTable(src = mygrid, dst = dest_fsgt, measure = "duration")
df7 <- data.frame(df7$duration)
write.csv(df7, "data-conso/grid-bike-duration_fsgt.csv", row.names = FALSE)
df7 <- read.csv("data-conso/grid-bike-duration_fsgt.csv")
colnames(df7) <- as.character(dest_fsgt$osm_id)
time <- data.frame(mygrid$ID, apply(df7, 1, min)) # find minimum value
colnames(time) <- c("ID", "TIME_FSGT")
mygrid <- merge(mygrid, time, by = "ID", all.x = TRUE) # merge time to grid

# Export grid 
st_write(mygrid, "data-conso/mygrid.geojson")
mygrid <- st_read("data-conso/mygrid.geojson")
com <- st_read("data-conso/com.geojson")
com <- st_transform(com, 2154)

# Compute isochrones
# define breaks (based on quantie analysis)
# library(devtools) this package will be soon available on the CRAN
# remotes::install_github("riatelab/mapiso") installation from the github repository before that
library(mapiso)
thr <- c(0, 2.5, 5, 7.5, 10, 12.5, 15, 20, 25, 30, max(mygrid$TIME_FSGT))
iso_all <- mapiso(x = mygrid, var = "TIME_ALL", breaks = thr, mask = paris5k)
iso_fsgt <- mapiso(x = mygrid, var = "TIME_FSGT", breaks = thr,  mask = paris5k)
iso_priv <- mapiso(x = mygrid, var = "TIME_PRIV", breaks = thr,  mask = paris5k)

# Transform in 4326 for observable integration
iso_all <- st_transform(iso_all, 4326)
iso_fsgt <- st_transform(iso_fsgt, 4326)
iso_priv <- st_transform(iso_priv, 4326)

## 4.3 A bike trip to visit all the FSGT climbing areas ? ----
# Keep only climbing areas in the study area
dest_fsgt <- st_transform(dest_fsgt, 2154)
dest_fsgt <- st_intersection(dest_fsgt, paris_5k)
dest_fsgt <- st_transform(dest_fsgt, 4326)

trip <- osrmTrip(loc = dest_fsgt)
trip <- trip[[1]]$trip
sum(trip$distance)
sum(trip$duration)


# 5. Accessibility indicator creation (IRIS) ----
# Name of the nearest structure
df <- read.csv("data-conso/bike-duration.csv", row.names = "X")
colnames(df) <- as.character(dest$osm_id)
osm_id <- colnames(df)[apply(df, 1, which.min)] # Name
osm_id <- data.frame(osm_id, stringsAsFactors = FALSE)
osm_id$iris <- row.names(df)
osm_id <- merge(osm_id, poi[,c("osm_id", "name", "federation")], 
                by = "osm_id", all.x = TRUE)

# Time to the nearest climbing area
time <- apply(df, 1, min) # Time
time <- data.frame(time, stringsAsFactors = FALSE)
time$iris <- row.names(time)
osm_id <- merge(osm_id, time, by = "iris", all.x = TRUE)
osm_id$geometry <- NULL

# Number of climbing area at less than 15 minutes by bike
n15mn <- df
n15mn <- data.frame(df, stringsAsFactors = FALSE)
n15mn[n15mn <= 15] <- 1
n15mn[n15mn > 15] <- 0
n15mn$N <- rowSums(n15mn)
n15mn$iris <- row.names(n15mn)
osm_id <- merge(osm_id, n15mn[,c("iris", "N")], by = "iris",
                all.x = TRUE)
osm_id <- osm_id[,c(1,3:6)]
colnames(osm_id) <- c("CODE_IRIS", "ALL_NAME", "TYPE_STRUCT", "ALL_TIME",
                      "N_15MN")
iris <- merge(iris, osm_id, by = "CODE_IRIS", all.x = TRUE)

# Prive climbing club (fees $$$)
# Name of the nearest structure
df2 <- read.csv("data-conso/bike-duration-priv.csv", row.names = "X")
colnames(df2) <- as.character(dest_priv$osm_id)
osm_id <- colnames(df2)[apply(df2, 1, which.min)] # Name
osm_id <- data.frame(osm_id, stringsAsFactors = FALSE)
osm_id$iris <- row.names(df2)
osm_id <- merge(osm_id, poi[,c("osm_id", "name", "type")], 
                by = "osm_id", all.x = TRUE)

# Time to the nearest climbing area
time <- apply(df2, 1, min) # Time
time <- data.frame(time, stringsAsFactors = FALSE)
time$iris <- row.names(time)
osm_id <- merge(osm_id, time, by = "iris", all.x = TRUE)
osm_id$geometry <- NULL

# Number of climbing area at less than 15 minutes by bike
n15mn <- df2
n15mn <- data.frame(df2, stringsAsFactors = FALSE)
n15mn[n15mn <= 15] <- 1
n15mn[n15mn > 15] <- 0
n15mn$N <- rowSums(n15mn)
n15mn$iris <- row.names(n15mn)
osm_id <- merge(osm_id, n15mn[,c("iris", "N")], by = "iris",
                all.x = TRUE)
osm_id <- osm_id[,c(1,3,5:6)]
colnames(osm_id) <- c("CODE_IRIS", "PRIV_NAME", "PRIV_TIME",
                      "N_PRIV_15MN")
iris <- merge(iris, osm_id, by = "CODE_IRIS", all.x = TRUE)

# FFME associative structure
# Name of the nearest structure
df3 <- read.csv("data-conso/bike-duration-ffme.csv", row.names = "X")
colnames(df3) <- as.character(dest_ffme$osm_id)
osm_id <- colnames(df3)[apply(df3, 1, which.min)] # Name
osm_id <- data.frame(osm_id, stringsAsFactors = FALSE)
osm_id$iris <- row.names(df3)
osm_id <- merge(osm_id, poi[,c("osm_id", "name", "type")], 
                by = "osm_id", all.x = TRUE)

# Time to the nearest climbing area
time <- apply(df3, 1, min) # Time
time <- data.frame(time, stringsAsFactors = FALSE)
time$iris <- row.names(time)
osm_id <- merge(osm_id, time, by = "iris", all.x = TRUE)
osm_id$geometry <- NULL

# Number of climbing area at less than 15 minutes by bike
n15mn <- df3
n15mn <- data.frame(df3, stringsAsFactors = FALSE)
n15mn[n15mn <= 15] <- 1
n15mn[n15mn > 15] <- 0
n15mn$N <- rowSums(n15mn)
n15mn$iris <- row.names(n15mn)
osm_id <- merge(osm_id, n15mn[,c("iris", "N")], by = "iris",
                all.x = TRUE)
osm_id <- osm_id[,c(1,3,5:6)]
colnames(osm_id) <- c("CODE_IRIS", "FFME_NAME", "FFME_TIME",
                      "N_FFME_15MN")
iris <- merge(iris, osm_id, by = "CODE_IRIS", all.x = TRUE)

# FSGT associative structure
# Name of the nearest structure
df4 <- read.csv("data-conso/bike-duration-fsgt.csv", row.names = "X")
colnames(df4) <- as.character(dest_fsgt$osm_id)
osm_id <- colnames(df4)[apply(df4, 1, which.min)] # Name
osm_id <- data.frame(osm_id, stringsAsFactors = FALSE)
osm_id$iris <- row.names(df4)
osm_id <- merge(osm_id, poi[,c("osm_id", "name", "type")], 
                by = "osm_id", all.x = TRUE)

# Time to the nearest climbing area
time <- apply(df4, 1, min) # Time
time <- data.frame(time, stringsAsFactors = FALSE)
time$iris <- row.names(time)
osm_id <- merge(osm_id, time, by = "iris", all.x = TRUE)
osm_id$geometry <- NULL

# Number of climbing area at less than 15 minutes by bike
n15mn <- df4
n15mn <- data.frame(df4, stringsAsFactors = FALSE)
n15mn[n15mn <= 15] <- 1
n15mn[n15mn > 15] <- 0
n15mn$N <- rowSums(n15mn)
n15mn$iris <- row.names(n15mn)
osm_id <- merge(osm_id, n15mn[,c("iris", "N")], by = "iris",
                all.x = TRUE)
osm_id <- osm_id[,c(1,3,5:6)]
colnames(osm_id) <- c("CODE_IRIS", "FSGT_NAME", "FSGT_TIME",
                      "N_FSGT_15MN")
iris <- merge(iris, osm_id, by = "CODE_IRIS", all.x = TRUE)




# 6. Characterise the POI neighbourhood ----
t.df <- data.frame(t(df))
colnames(t.df) <- iris10k[iris10k$TYP_IRIS == "H",]$CODE_IRIS
t.df$osm_id <- dest$osm_id
t.df <- t.df[t.df$osm_id %in% poi$osm_id,]

poi_socio <- data.frame(matrix(nrow = 0, ncol = 5))
colnames(poi_socio) <- c("osm_id", "SUM_POP18", "MIN_REV19", "MOY_REV19", "MAX_REV19")

for (i in 1:nrow(t.df)){
  tmp1 <- t.df[, t.df[i, ] < 15]
  tmp2 <- data.frame(CODE_IRIS = colnames(tmp1))
  tmp2 <- merge(tmp2, iris10k[,c("CODE_IRIS", "P18_POP", "DISP_MED19")],
             all.x = TRUE)
  
  poi_socio[i,1] <- row.names(tmp1)[i]
  poi_socio[i,2] <- sum(tmp2$P18_POP, na.rm = TRUE)
  poi_socio[i,3] <- min(tmp2$DISP_MED19, na.rm = TRUE)
  poi_socio[i,4] <- mean(tmp2$DISP_MED19, na.rm = TRUE)
  poi_socio[i,5] <- max(tmp2$DISP_MED19, na.rm = TRUE)
  }

poi <- merge(poi, poi_socio, by = "osm_id", all.x = TRUE)

# Correct MurMur and Rename ESC15
poi[17,"climbing_length"] <- 17

poi[16,"name"] <- "ESC 15 - La Plaine"
poi[31,"name"] <- "ESC 15 - Croix Nivert"

# 7. Simplify geometries for data visualization
library(rmapshaper)
iris <- ms_simplify(iris, keep = 0.09)

# Communes aggregation (layout)
com <- aggregate(iris[,c("NOM_COM")],
                 by = list(iris$NOM_COM),
                 FUN = head, 1)

# Extract IRIS at less than 15 minutes by bike
iris15 <- iris[iris$ALL_TIME < 15,]
iris15 <- iris15[!is.na(iris15$ALL_TIME),]

st_write(com, "data-conso/com.geojson")
st_write(iris, "data-conso/iris.geojson")
st_write(iris15, "data-conso/iris15.geojson")
st_write(poi, "data-conso/poi.geojson")
st_write(trip, "data-conso/trip.geojson")
st_write(iso_all, "data-conso/iso_all.geojson")
st_write(iso_fsgt, "data-conso/iso_fsgt.geojson")
st_write(iso_priv, "data-conso/iso_priv.geojson")
st_write(trip, "data-conso/trip.geojson")



# For plots
## Time * federation
data_iris <- data.frame(matrix(nrow = 0, ncol = 2))
colnames(data_iris) <- c("TIME", "TYPE")

tmp <- st_set_geometry(iris, NULL)
TIME <- tmp$PRIV_TIME[!is.na(tmp$PRIV_TIME)]
TYPE <- rep("Private", length(TIME))
df <- data.frame(TIME, TYPE)

data_iris <- rbind(data_iris, df)

TIME <- tmp$FSGT_TIME[!is.na(tmp$FSGT_TIME)]
TYPE <- rep("FSGT", length(TIME))
df <- data.frame(TIME, TYPE)

data_iris <- rbind(data_iris, df)

TIME <- tmp$FFME_TIME[!is.na(tmp$FFME_TIME)]
TYPE <- rep("FFME", length(TIME))
df <- data.frame(TIME, TYPE)

data_iris <- rbind(data_iris, df)
write.csv(data_iris, "data-conso/time_federation_iris.csv")