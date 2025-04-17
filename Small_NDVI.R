NDVI_raster = rast("NDVI_BayArea.tif")

## Get summary of raster data
NDVI_raster
sf_rast<-crop(NDVI_raster, ext(-122.53, -122.3, 37.6191, 37.9))
write_rds(sf_rast,"/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/sf_rast.rds")
