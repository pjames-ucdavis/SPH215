#Clean up NDVI
library(terra)

red <- rast("/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/LC08_L2SP_013030_20130930_20200912_02_T1_SR_B4.TIF")
nir <- rast("/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/LC08_L2SP_013030_20130930_20200912_02_T1_SR_B5.TIF")

ndvi <- (nir - red) / (nir + red)

plot(ndvi)
crs(ndvi)

library(sf)

ema <- read_csv("studentlife_stress_u00_subset.csv")

ema_sf <- st_as_sf(
  ema,
  coords = c("longitude", "latitude"),
  crs = 4326
)

# Transform points to the NDVI raster CRS
ema_proj <- st_transform(ema_sf, crs(ndvi))

study_area <- st_buffer(
  st_union(ema_proj),
  dist = 5000
)

ndvi_dartmouth <- crop(
  ndvi,
  vect(study_area)
)

names(ndvi_dartmouth) <- "NDVI_mean"

plot(ndvi_dartmouth)
summary(ndvi_dartmouth)

writeRaster(
  ndvi_dartmouth,
  "NDVI_rast_dartmouth.tif",
  overwrite = TRUE
)
