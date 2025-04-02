library(MapGAM)
download.file("https://raw.githubusercontent.com/pjames-ucdavis/SPH215/refs/heads/main/CA_Cancer_Data.rds", "ca_cancer.rds", mode = "wb")
#Read in Cancer Dataset
cancer <- readRDS("ca_cancer.rds")

#Get names of columns or variables
head(cancer)

cancer_projected = st_as_sf(cancer, crs=4269)
head(cancer_projected)

library(magrittr) #for the pipe
df <- cancer_projected %>%
  dplyr::mutate(lon = sf::st_coordinates(.)[,1],
                lat = sf::st_coordinates(.)[,2])
df

library(tidygeocoder)
reverse <- df %>%
  reverse_geocode(lat = lat, long = lon, method = 'osm',
                  address = address_found, full_results = TRUE) 
  

saveRDS(reverse, file="/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/addreses_Cancer.rds")