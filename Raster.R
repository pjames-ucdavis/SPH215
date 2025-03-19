
### Step 1. Install and Load Packages


install.packages("terra") # for analysis using raster data 
install.packages("sf") # has some spatial commands needed for this analysis 
install.packages("rgdal") # allows manipulation of shapefiles 
install.packages("tidyverse") # makes data management easier 
install.packages("gtools") # cross-tabs
install.packages("gmodels") # also for cross-tabs
install.packages("tmap") # pretty maps

library(terra)
library(sf)
library(dplyr)
library(tmap)
library(gtools)
library(gmodels)
library(ggplot2)


### Step 2. Read in Shapefiles and Check Projections

## Good practice to set a working directory
setwd("/Users/peterjames/Library/CloudStorage/GoogleDrive-nhpja@channing.harvard.edu/My Drive/EH 249/2023 Course/Lectures/Lecture 2 GIS Lab/Lab Materials for R/")

##  Part 2.1 - Read in Points Spatial Dataset (SAME as in code from Lecture 2) ########    

## We are reading in a built-in dataset of ovarian cancer patients in the SF Bay Area. 
## Event is coded 1/0 where 1 indicates death, 0 indicates survived at end of follow-up. 
cancer = readRDS("CA_Cancer_Data.rds")

## Make dataset spatial, assigning NAD83 projection again
cancer_projected = st_as_sf(cancer, crs=4269)



### Step 2.2. Read in Raster Data

## Read in raster
NDVI_raster = rast("NDVI_BayArea.tif")

## Get summary of raster data
NDVI_raster

## Plot the raster
tmap_mode("view")

# Also option for tmap_mode("view")


## Plot the raster on a map
NDVI_map = tm_shape(NDVI_raster) +
  tm_raster(style = "cont") +
  tm_legend(outside = TRUE)
NDVI_map



### Step 2.3. Check Projections of Raster and Points Spatial Datasets
## Checking projections
st_crs(cancer)
st_crs(NDVI_raster)

## Setting coordinate reference system (CRS) to North American Datum 1983 (NAD83) ## per study documentation
cancer_projected = st_as_sf(cancer, crs=4269)

## And then transform cancer data points to match projection of NDVI raster
cancer_transformed = st_transform(cancer_projected,st_crs(NDVI_raster))
st_crs(cancer_transformed)

st_crs(cancer_transformed)==st_crs(NDVI_raster)

### Step 3. Make Maps

## Check to make sure maps can be overlayed

## Add points for cancer data to map of raster
NDVI_cancer_map = NDVI_map + tm_shape(cancer_transformed)+tm_dots(size=0.1,alpha=0.8)
NDVI_cancer_map

##Plot both maps side by side
tmap_arrange(NDVI_map,NDVI_cancer_map)

### Step 4. Extract Raster Values to Points and Merge Datasets

## Get one vector with NDVI extracted to point data
NDVI_cancer = data.frame(cancer_transformed,extract(NDVI_raster, cancer_transformed))

## Check data to make sure it looks OK; hint: compare to cancer_transformed dataframe-- ## what is different?
head(NDVI_cancer)
hist(NDVI_cancer$NDVI_BayArea)
### Step 6. Export Data for Further Analysis

write.csv(NDVI_cancer, file = "NDVI_Cancer_SF_Export.csv")
