
require(reshape2)
library(leaflet)

# exemples de visualisations testées


JCDecaux.data_in <- read.csv2("stations-velib-disponibilites-en-temps-reel.csv")

JCDecaux.data_prep <- data.frame(JCDecaux.data_in)
JCDecaux.data_viz = transform(JCDecaux.data_prep, 
                              position = colsplit(position, pattern=",", names = c('lat', 'lng')))
JCDecaux.data_viz = cbind (JCDecaux.data_viz, JCDecaux.data_viz$position)

head(JCDecaux.data_viz)

#names(JCDecaux.data_viz)[names(JCDecaux.data_viz) == 'position.lng'] <- 'lng'
#names(JCDecaux.data_viz)[names(JCDecaux.data_viz) == 'position.lat'] <- 'lat'


# Exemple 1 avec leaflet
# m <- leaflet(JCDecaux.data_viz) %>%
#   addTiles() %>% 
#   addCircles(lat = ~lat, lng = ~lng, radius = ~bike_stands) %>%
#   addMarkers(lng = 2.2965736, lat = 48.8152334, popup="Cepe - prévoir les tablettes de chocolat pour ressortir")



# autre exemple de visu de carto en alternative
## Map from URL : http://maps.googleapis.com/maps/api/staticmap?center=houston&zoom=14&size=640x640&scale=2&maptype=terrain&language=en-EN&sensor=false
## Information from URL : http://maps.googleapis.com/maps/api/geocode/json?address=houston&sensor=false


# Exemple 2 avec rbokeh
# library(rbokeh)
# 
# gmap(lat = 40.73306, lng = -73.97351,zoom =12,#lat = 48.8152334, lng = 2.2965736, zoom = 12,
#      width = 680, height = 600 , map_type = "roadmap") %>%
#   ly_points(lat, lng, data = JCDecaux.data_viz, hover = c(status, bike_stands))
# 
# gmap(lat = 40.73306, lng = -73.97351, zoom = 12, width = 680, height = 600)


### Fichier 2
OpenDataParis.data_in <- read.csv2("Paris.csv", sep = ",")
head(OpenDataParis.data_in)
# moins riche que JCDecaux

### Fichier 3
library(jsonlite)
# json_file <- "http://api.worldbank.org/country?per_page=10&region=OED&lendingtype=LNX&format=json"
json_file1 <- "input_Paris.json"
json_data1 <- read_json(path=json_file1, simplifyVector = TRUE)
head(json_data1)

# #### Fichier 4 # json invalide - prendre le data_all_Paris avec date.gz à la place
# json_file2 <- "data_all_Paris.json"
# json_data2 <- read_json(path=json_file2, simplifyVector = TRUE, header = T)
# head(json_data2)

library(anytime)
anytime(1352068320)

# #### Fichier 5 - json en streaming
# json_file3 <- "input_Paris.json"
# json_data3 <- read_json(path=json_file3, simplifyVector = TRUE)
# head(json_data3)

# développements à reprendre à partir d'ici :

# imports des modules
library(jsonlite)
library(anytime)

#chargement des fichiers
json_file <- "data/data_all_Paris/data_all_Paris.jjson_2017-01-01-1483248351.gz" 
# Placer les données dans un répertoire data/data_all_Paris/ à côté du script
dat <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))
length(dat)
# On obtient une liste contenant l'ensemble des df des données collectées sur 1 mois, le pas temporel est de 20 minutes.

# Optimum pour itérer sur la liste : lapply à privilégier sur une boucle for ...
avg_bike_stands <- unlist(lapply(dat, function(x) mean(x$bike_stands)))
time <- unlist(lapply(dat, function(x) anytime(x$download_date)))
hist(avg_bike_stands)
unique(avg_bike_stands)
plot(time, avg_bike_stands)
