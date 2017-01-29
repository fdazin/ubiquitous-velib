library(jsonlite)
#library(anytime)
library(sqldf)
library(plyr)
#library(lubridate)

#chargement des fichiers
setwd("~/Documents/dev/Cepe/ubiquitous-velib")
json_file <- "data/data_all_Paris/data_all_Paris.jjson_2017-01-01-1483248351.gz" 
# Placer les données dans un répertoire data/data_all_Paris/ à côté du script
dat <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))
length(dat)
# On obtient une liste contenant l'ensemble des df des données collectées sur 1 mois, le pas temporel est de 20 minutes.
dat_full <- dat
remove(dat)

# single element example
data <- data.frame(dat_full[1])
#data[date_temps] <- lapply(data[download_date], anytime) # a debugger, renvoie NA
#example avec tous les éléments
data_frame_full  <- rbind.fill(dat_full)

data$download_datetemps<-as.POSIXct(data$download_date, origin="1970-01-01", tz="UTC")
data$lastupdt_datetemps<-as.POSIXct(data$last_update, origin="1970-01-01", tz="UTC")

#export vers une base sqlite
file.remove("SQLiteData/Test.sqlite")
con <- dbConnect(RSQLite::SQLite(), dbname="SQLiteData/Test.sqlite")
dbWriteTable(con, name="raw_data", value = data_frame_full , row.names = FALSE)