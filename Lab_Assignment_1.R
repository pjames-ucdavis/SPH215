innout <- read_csv("/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/innout.csv")
glimpse(innout)

innout_final <- 
  innout %>%
  unite("store address", "Address", "City", "State", "Zip Code", sep=" ")

head(innout_final)

write_csv(innout_final, "/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/innout_final.csv")

download.file("https://raw.githubusercontent.com/pjames-ucdavis/SPH215/refs/heads/main/innout_final.csv", "innout_final.csv", mode = "wb")
innout_final <- read_csv("innout_final.csv")



innout_geo      <- geocode(innout_final, address = "store address",
                          method = "arcgis")
glimpse(innout_geo)

summary(innout_geo$lat)
summary(innout_geo$long)

#Make spatial
innout_pts <- st_as_sf(innout_geo, coords=c("long","lat"), crs=4326)

st_crs(innout_pts)

innout_map = tm_shape(innout_pts) + tm_dots(col = "red", size = 0.3, alpha = 0.5)
innout_map
