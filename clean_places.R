# Read in PLACES data
places_ca<-read_csv("/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/PLACES_CA_Tracts_2024.csv")
glimpse(places_ca)
alameda<-filter(places_ca, LocationName == "06001401700")
glimpse(alameda)
table(alameda$Short_Question_Text)
table(alameda$MeasureId)

# Pick just Physical Inactivity
names(places_ca)
places_ca_lpa<-filter(places_ca, MeasureId == "LPA")
glimpse(places_ca_lpa)
summary(places_ca_lpa$Data_Value)

# Write .csv
write_csv(places_ca_lpa,"/Users/pjames1/Dropbox/UC Davis Folders/SPH 215 GIS and Public Health/Github_Website/SPH215/places_ca_lpa.csv")
