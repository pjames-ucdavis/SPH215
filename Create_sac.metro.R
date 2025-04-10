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
