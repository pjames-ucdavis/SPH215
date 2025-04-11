# Bring in data for Lab 3

library(tigris)
cb <- core_based_statistical_areas(year = 2023, cb = FALSE)
sac.metro <- filter(cb, grepl("Sacramento", NAME))
glimpse(sac.metro)
sac_map <- tm_shape(sac.metro) +   tm_polygons()
sac_map
write_rds(sac.metro,"/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/sac.metro.rds")

# test
url <- "https://github.com/pjames-ucdavis/SPH215/raw/main/sac.metro.rds"
download.file(url, destfile = "sac.metro.rds", mode = "wb")
data <- readRDS("sac.metro.rds")

#download Noli's park dataset

download.file(url = "https://raw.githubusercontent.com/crd230/data/master/spatiallab.zip", destfile = "spatiallab.zip")
unzip(zipfile = "spatiallab.zip")
getwd()
parks<-st_read("Parks.shp", stringsAsFactors = FALSE)
write_rds(parks,"/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/parks.rds")

# bring in sac city
pl <- places(state = "CA", year = 2018, cb = FALSE)
sac.city <- filter(pl, NAME == "Sacramento")

#Merge data on income with sac.city
ca.tracts <- get_acs(geography = "tract", 
                  year = 2023,
                  variables = c(medinc = "B19013_001"), 
                  state = "CA",
                  survey = "acs5",
                  output = "wide",
                  geometry = TRUE)
glimpse(ca.tracts)
glimpse(sac.city)
tm_shape(ca.tracts) +
  tm_polygons() + tm_shape(sac.city) +
  tm_polygons(col = "blue") 


sac.city.tracts.w = st_join(ca.tracts, sac.city, join = st_within, left=FALSE)

tm_shape(sac.city.tracts.w) +
  tm_polygons(col = "blue") +
  tm_shape(sac.city) +
  tm_borders(col = "red")

sac.city.w <- st_join(ca.tracts, sac.city, join = st_within, left=FALSE)
glimpse(sac.city.w)

tm_shape(sac.city.w) +
  tm_polygons(col = "blue") 


write_rds(sac.city.w,"/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/sac.city.rds")
