library(jsonlite)
library(sqldf)
library(plyr)


# La fonction suivante prend en argument un nom de fichier json et une base sqlite de destination,
# et remplit la base à partir des données contenues dans le fichier json.


data_fromJSON_to_SQLite <- function(json_file,SQLite_db ) {
  dat_full <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))
  # On obtient une liste contenant l'ensemble des df des données collectées sur 1 mois, le pas temporel est de 20 minutes.

  # single element example
  #data <- data.frame(dat_full[1])

  #example avec tous les éléments
  data_frame_full  <- rbind.fill(dat_full)

  # Conversion des informations temporelles
  data_frame_full$download_datetemps<-as.POSIXct(data_frame_full$download_date, origin="1970-01-01", tz="UTC")
  data_frame_full$lastupdt_datetemps<-as.POSIXct(data_frame_full$last_update/1000, origin="1970-01-01", tz="UTC")

  #export vers la base sqlite
  #file.remove("SQLiteData/Test.sqlite") # peut être nécessaire si l'on veut remplacer le contenu de la base
  con <- dbConnect(RSQLite::SQLite(), dbname="SQLiteData/Test.sqlite")
  dbWriteTable(con, name="raw_data", value = data_frame_full , row.names = FALSE)
  
  }

setwd("~/Documents/dev/Cepe/ubiquitous-velib")
# Placer les données dans un répertoire data/data_all_Paris/ à côté du script
json_file <- "data/data_all_Paris/data_all_Paris.jjson_2017-01-01-1483248351.gz" 
SQLite_db <- "SQLiteData/Test.sqlite"

data_fromJSON_to_SQLite(json_file,SQLite_db)



