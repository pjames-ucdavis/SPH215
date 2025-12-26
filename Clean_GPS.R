library(dplyr)
library(readr)
library(purrr)
library(ggplot2)
library(gganimate)
library(readr)
library(lubridate)

# Set the path to your GPS folder
folder_path <- "/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/GPS/gps/Oct"

# List all CSV files in the folder
csv_files <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)

# Read and bind all CSV files into one data frame
gps_oct <- csv_files %>%
  map_dfr(read_csv)

# Optional: Save combined file
write_csv(gps_oct, file.path(folder_path, "gps_oct.csv"))
write_rds(gps_oct, file.path(folder_path, "gps_oct.rds"))

# Set the path to your GPS folder
folder_path <- "/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/GPS/gps/Apr"

# List all CSV files in the folder
csv_files <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)

# Read and bind all CSV files into one data frame
gps_apr <- csv_files %>%
  map_dfr(read_csv)

# Optional: Save combined file
write_csv(gps_apr, file.path(folder_path, "gps_apr.csv"))
write_rds(gps_apr, file.path(folder_path, "gps_apr.rds"))


# Set the path to your GPS folder
folder_path <- "/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/GPS/gps/Apr/Apr20_30"

# List all CSV files in the folder
csv_files <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)

# Read and bind all CSV files into one data frame
gps_apr25_30 <- csv_files %>%
  map_dfr(read_csv)

# Optional: Save combined file
write_csv(gps_apr25_30, "/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/GPS/gps/Apr/Apr20_30/Compiled/gps_apr25_30.csv")
write_rds(gps_apr25_30, "/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/GPS/gps/Apr/Apr20_30/Compiled/gps_apr25_30.rds")
