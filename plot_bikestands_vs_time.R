library(jsonlite)
library(anytime)
library(ggplot2)

#chargement des fichiers
setwd("~/Documents/dev/Cepe/ubiquitous-velib")
json_file <- "data/data_all_Paris/data_all_Paris.jjson_2017-01-01-1483248351.gz" 
# Placer les données dans un répertoire data/data_all_Paris/ à côté du script
dat <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))
length(dat)
# On obtient une liste contenant l'ensemble des df des données collectées sur 1 mois, le pas temporel est de 20 minutes.
dat_full <- dat
dat <- dat_full[1:72] # Une journée de données


# Optimum pour itérer sur la liste : lapply à privilégier sur une boucle for ...
avg_bike_stands <- lapply(dat, function(x) mean(x$bike_stands))
time <-(lapply(lapply(dat, function(x) mean(x$download_date)), function(x) anytime(x)))
# au lieu de faire la moyenne du temps, on pourrait se contenter de ne récupérer que le premier element ...

##hist(avg_bike_stands)
#unique(avg_bike_stands)
#plot(time, avg_bike_stands)

bike_stands_df <- data.frame(cbind(time, avg_bike_stands))
bike_stands_df$time<-as.POSIXct(bike_stands_df$time, origin="1970-01-01", tz="UTC")
plot(bike_stands_df$time, bike_stands_df$avg_bike_stands)

# So far, so good, mais après ...

#ggplot(bike_stands_df) %>% geom_point(aes(x=~time, y=~avg_bikes_stands)) # Erreur : ggplot2 doesn't know how to deal with data of class uneval

