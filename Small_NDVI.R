NDVI_raster = rast("/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/NDVI_BayArea.tif")

## Get summary of raster data
NDVI_raster
NDVI_rast<-crop(NDVI_raster, ext(-122.6, -122.2, 37.6, 38.1))

tmap_mode("plot")

NDVI_map = tm_shape(NDVI_rast) +
  tm_raster(style = "cont") +
  tm_legend(outside = TRUE)
NDVI_map

writeRaster(sf_rast,"/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/NDVI_rast.tif")
