library(jsonlite)
library(sqldf)
library(plyr)
library(DBI)
library(dtplyr)
library(data.table)
library(magrittr)

# TODO : initialiser la base sqlite si elle est absente, et travailler en append si des données sont déja présentes.
#         Prévoir de nettoyer la base pour ne garder que les lignes uniques.



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
  dbWriteTable(con, name="raw_data", value = data_frame_full , row.names = FALSE) # Append à ajouter pour plus tard
  
  }


data_fromSQLITE_to_df <- function(SQLite_db, tbl_name) {
  con <- dbConnect(RSQLite::SQLite(), dbname=SQLite_db )
  df <- dbReadTable(con, tbl_name)
  dbDisconnect(con)
  return (df)
  }


###############################################################################
# Comment convertire le json intitial et générer les fichiers SQLITE ... lent
setwd("~/Documents/dev/Cepe/ubiquitous-velib")
# Placer les données dans un répertoire data/data_all_Paris/ à côté du script
json_file <- "data/data_all_Paris/data_all_Paris.jjson_2017-01-01-1483248351.gz" 
SQLite_db <- "SQLiteData/Test.sqlite"

data_fromJSON_to_SQLite(json_file,SQLite_db)


###############################################################################
# Comment charger les données traitées en df, beaucoup plus rapide !
SQLite_db <- "SQLiteData/Test.sqlite"
tbl_name <- "raw_data" 
raw_data <- data_fromSQLITE_to_df(SQLite_db, tbl_name)
raw_data$download_datetemps<-as.POSIXct(raw_data$download_date, origin="1970-01-01", tz="UTC")
raw_data$lastupdt_datetemps<-as.POSIXct(raw_data$last_update/1000, origin="1970-01-01", tz="UTC")


###############################################################################
# Comment explorer les données : station 1013, évolution de la disponibilité
data <- tbl_df(raw_data)
filter(data, number == 1013) %>% select(download_datetemps, available_bikes) %>% plot(type = 'l', lty = 1)


###############################################################################
# Exploration des données par durée d'indisponibilité compléte : aucun Velib disponible

identifier_vides_continus <- function(x){ tmp<-cumsum(!x);tmp-cummax(x*tmp)} 
data <- tbl_df(raw_data)
data <- filter(data, number == 1013) 

data$unempty_station <- 1
data$unempty_station[data$available_bikes == 0]<-0

data$empty_station <- 0
data$empty_station[data$available_bikes == 0]<-1

data$vides_continus = cumsum(!data$unempty_station)-cummax(data$unempty_station *cumsum(!data$unempty_station ))

data$vides_continus_starts <- 0
data$vides_continus_starts[data$vides_continus==1] <- 1
data$no_evenement_vides_continus <- cumsum(data$vides_continus_starts)

durée <- 1/3 * filter(data, empty_station == 1) %>% select(no_evenement_vides_continus) %>% table %>% t()
hist(durée, main = 'Répartition des durées (en h) des périodes où la station 1013 est vide de tout Velib')
