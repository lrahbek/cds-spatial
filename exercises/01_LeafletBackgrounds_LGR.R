###   GETTING STARTED WITH LEAFLET


## Choose favorite backgrounds in:
# https://leaflet-extras.github.io/leaflet-providers/preview/
## beware that some need extra options specified

# Packages
pacman::p_load("leaflet", "htmltools", "googlesheets4", "tidyverse")
#install.packages("leaflet")
#install.packages("htmltools") 
#install.packages("googlesheets4")

# Example with Markers
#library(leaflet)

popup = c("Robin", "Jakub", "Jannes")

leaflet() %>%
  addProviderTiles("Esri.WorldPhysical") %>% 
 #addProviderTiles("Esri.WorldImagery") %>% 
  addAwesomeMarkers(lng = c(-3, 23, 11),
                    lat = c(52, 53, 49), 
                    popup = popup)


## Sydney with setView
leaflet() %>%
  addTiles() %>%
  addProviderTiles("Esri.WorldImagery", 
                   options = providerTileOptions(opacity=0.5)) %>% 
  setView(lng = 151.005006, lat = -33.971, zoom = 10)


# Europe with Layers
leaflet() %>% 
  addTiles() %>% 
  setView(lng = 2.34, lat = 48.85, zoom = 5 ) %>% 
  addProviderTiles("Esri.WorldPhysical", group = "Physical") %>% 
  addProviderTiles("Esri.WorldImagery", group = "Aerial") %>% 
  addProviderTiles("MtbMap", group = "Geo") %>% 
addLayersControl(
  baseGroups = c("Geo","Aerial", "Physical"),
  options = layersControlOptions(collapsed = T))

# note that you can feed plain Lat Long columns into Leaflet
# without having to convert into spatial objects (sf), or projecting


########################## SYDNEY HARBOUR DISPLAY WITH LAYERS

# Set the location and zoom level
leaflet() %>% 
  setView(151.2339084, -33.85089, zoom = 13) %>%
  addTiles()  # checking I am in the right area


# Bring in a choice of esri background layers  

l_aus <- leaflet() %>%   # assign the base location to an object
  setView(151.2339084, -33.85089, zoom = 13) 
  

esri <- grep("^Esri", providers, value = TRUE)

for (provider in esri) {
  l_aus <- l_aus %>% addProviderTiles(provider, group = provider)
}

AUSmap <- l_aus %>%
  addLayersControl(baseGroups = names(esri),
                   options = layersControlOptions(collapsed = F)) %>%
  addMiniMap(tiles = esri[[1]], toggleDisplay = TRUE,
             position = "bottomright") %>%
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters",
    activeColor = "#3D535D",
    completedColor = "#7D4479") %>% 
  htmlwidgets::onRender("
                        function(el, x) {
                        var myMap = this;
                        myMap.on('baselayerchange',
                        function (e) {
                        myMap.minimap.changeLayer(L.tileLayer.provider(e.name));
                        })
                        }") %>% 
addControl("", position = "topright")

AUSmap
################################## SAVE FINAL PRODUCT

# Save map as a html document (optional, replacement of pushing the export button)
# only works in root
#library(htmlwidgets) # from htmltools
pacman::p_load("htmlwidgets")
saveWidget(AUSmap, "AUSmap.html", selfcontained = TRUE)
#########################################################
#
# Task 1: Create a Danish equivalent with esri layers, call it DKmap
l_dk <- leaflet() %>%   # assign the base location to an object
  setView(10, 56, zoom = 13) 


for (provider in esri) {
  l_dk <- l_dk %>% addProviderTiles(provider, group = provider)
}

DKmap <- l_dk %>%
  addLayersControl(baseGroups = names(esri),
                   options = layersControlOptions(collapsed = F)) %>%
  addMiniMap(tiles = esri[[1]], toggleDisplay = TRUE,
             position = "bottomright") %>%
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters",
    activeColor = "#3D535D",
    completedColor = "#7D4479") %>% 
  htmlwidgets::onRender("
                        function(el, x) {
                        var myMap = this;
                        myMap.on('baselayerchange',
                        function (e) {
                        myMap.minimap.changeLayer(L.tileLayer.provider(e.name));
                        })
                        }") %>% 
  addControl("", position = "topright")

DKmap

saveWidget(DKmap, "DKmap.html", selfcontained = TRUE)

# Task 2: Start collecting spatial data into a spreadsheet: https://docs.google.com/spreadsheets/d/1PlxsPElZML8LZKyXbqdAYeQCDIvDps2McZx1cTVWSzI/edit#gid=1817942479
#
#
################################## ADD DATA TO LEAFLET
# Libraries
#library(tidyverse)
#library(googlesheets4)
#library(leaflet)

gs4_deauth() # if the authentication is not working for you

places <- read_sheet("https://docs.google.com/spreadsheets/d/1PlxsPElZML8LZKyXbqdAYeQCDIvDps2McZx1cTVWSzI/edit#gid=1817942479",
                     range = "SA2024",
                     col_types = "cccnncnc")
glimpse(places)

leaflet() %>% 
  addTiles() %>% 
  addMarkers(lng = places$Longitude, 
             lat = places$Latitude,
             popup = places$Description)

#########################################################
#
# Task 3: Read in the googlesheet data you and your colleagues populated with data and display it over your DKmap . 
# The googlesheet is at https://docs.google.com/spreadsheets/d/1PlxsPElZML8LZKyXbqdAYeQCDIvDps2McZx1cTVWSzI/edit#gid=1817942479

#########################################################

DKmap %>% 
  addMarkers(lng = places$Longitude, 
             lat = places$Latitude,
             popup = places$Description)

# Task 4: chicago crime stats 
cc <- read_csv("data/ChicagoCrimes2017.csv")

cc_leaf <- leaflet() %>% 
  addTiles() %>% 
  addMarkers(lng = cc$Longitude, 
             lat = cc$Latitude, 
             popup = cc$Description, 
             clusterOptions = 1)
  
#heatmap
pacman::p_load('leaflet.extras')

addHeatmap(cc_leaf)

