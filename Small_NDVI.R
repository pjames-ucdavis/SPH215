library(terra)
library(tmap)

NDVI_raster = rast("/Users/pjames1/Library/CloudStorage/GoogleDrive-nhpja@channing.harvard.edu/My Drive/2024 EH 249 Built Environment Nature and Health Course/Lectures/Lecture 2 GIS Lab/Lab Materials for R/Read-in Files /NDVI_BayArea.tif")

## Get summary of raster data
NDVI_raster
NDVI_rast<-crop(NDVI_raster, ext(-122.6, -122.2, 37.6, 38.1))

tmap_mode("plot")

NDVI_map = tm_shape(NDVI_rast) +
  tm_raster(style = "cont") +
  tm_legend(outside = TRUE)
NDVI_map

writeRaster(NDVI_rast,"/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/NDVI_rast2.tif", overwrite=TRUE)
#writeRaster(sf_rast,"/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/NDVI_BayArea.tif", overwrite=TRUE)

# Make smaller NDVI for GPS in Boston
gps_data <- read_csv("/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/gps_apr25_30.csv")  # Replace with your GitHub path or data folder

ndvi_raster <- rast("/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/GPS/NewEngland_270_2021-07-01.tif")  # Replace with your raster path
# Reproject GPS to match raster
gps_sf <- st_as_sf(gps_data, coords = c("longitude", "latitude"), crs = 4326)
gps_proj <- st_transform(gps_sf, crs = crs(ndvi_raster))

# Crop raster to a buffered extent around GPS points
bbox <- st_bbox(gps_proj)
buffer_deg_lat <- 0.0045
buffer_deg_lon <- 0.0055
bbox_buffer <- bbox
bbox_buffer["xmin"] <- bbox["xmin"] - buffer_deg_lon
bbox_buffer["xmax"] <- bbox["xmax"] + buffer_deg_lon
bbox_buffer["ymin"] <- bbox["ymin"] - buffer_deg_lat
bbox_buffer["ymax"] <- bbox["ymax"] + buffer_deg_lat

ndvi_crop <- crop(ndvi_raster, ext(bbox_buffer))
writeRaster(ndvi_crop,"/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/NDVI_rast_boston.tif", overwrite=TRUE)
