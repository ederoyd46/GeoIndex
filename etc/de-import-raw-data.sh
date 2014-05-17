#!/bin/bash

ORIG=$PWD
download=$PWD/Download

#Download data
if [ ! -d "$download/geo-data/postcode" ]; then
  mkdir -p $download/geo-data/postcode
  cd $download/geo-data/postcode
  curl -C - -O http://download.geonames.org/export/zip/DE.zip
  unzip DE.zip
  mongoimport --host localhost --db geo_data_de --collection PostalCode --drop --type tsv --file $download/geo-data/postcode/DE.txt -f countryCode,postalCode,placeName,adminName1,adminCode1,adminName2,adminCode2,adminName3,adminCode3,latitude,longitude,accuracy
  mongo localhost/geo_data_de --eval "db.PostalCode.ensureIndex({postalCode:1});"
fi

cd $ORIG

if [ ! -d "$download/geo-data/placename" ]; then
  mkdir -p $download/geo-data/placename
  cd $download/geo-data/placename
  curl -C - -O http://download.geonames.org/export/dump/DE.zip
  unzip DE.zip
  mongoimport --host localhost --db geo_data_de --collection PlaceName --drop --type tsv --file $download/geo-data/placename/DE.txt -f geonameid,name,asciiname,alternatenames,latitude,longitude,featureClass,featureCode,countryCode,cc2,admin1Code,admin2Code,admin3Code,admin4Code,population,elevation,dem,timezone,modificationDate
  mongo localhost/geo_data_de --eval "db.PlaceName.ensureIndex({name:1});"
fi

cd $ORIG

if [ ! -d "$download/geo-data/openstreetmap" ]; then
  mkdir -p $download/geo-data/openstreetmap
  cd $download/geo-data/openstreetmap
  curl -C - -O http://download.geofabrik.de/europe/germany/berlin-latest.osm.pbf
#  OSMImport localhost geo_data_de $download/geo-data/openstreetmap/berlin-latest.osm.pbf +RTS -K32M -RTS
fi


