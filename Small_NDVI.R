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

writeRaster(NDVI_rast,"/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/NDVI_rast.tif", overwrite=TRUE)
#writeRaster(sf_rast,"/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/NDVI_BayArea.tif", overwrite=TRUE)

