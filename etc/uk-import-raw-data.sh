#!/bin/bash

ORIG=$PWD
download=$PWD/Download

#Download data
if [ ! -f "$download/geo-data/postcode/GB_full.csv.zip" ]; then
  mkdir -p $download/geo-data/postcode
  cd $download/geo-data/postcode
  curl -C - -O http://download.geonames.org/export/zip/GB_full.csv.zip
  unzip GB_full.csv.zip
  mongoimport --host localhost --db geo_data --collection PostalCode --drop --type tsv --file $download/geo-data/postcode/GB_full.csv -f countryCode,postalCode,placeName,adminName1,adminCode1,adminName2,adminCode2,adminName3,adminCode3,latitude,longitude,accuracy
  mongo localhost/geo_data --eval "db.PostalCode.ensureIndex({postalCode:1});"
fi

cd $ORIG

if [ ! -f "$download/geo-data/placename/GB.zip" ]; then
  mkdir -p $download/geo-data/placename
  cd $download/geo-data/placename
  curl -C - -O http://download.geonames.org/export/dump/GB.zip
  unzip GB.zip
  mongoimport --host localhost --db geo_data --collection PlaceName --drop --type tsv --file $download/geo-data/placename/GB.txt -f geonameid,name,asciiname,alternatenames,latitude,longitude,featureClass,featureCode,countryCode,cc2,admin1Code,admin2Code,admin3Code,admin4Code,population,elevation,dem,timezone,modificationDate
  mongo localhost/geo_data --eval "db.PlaceName.ensureIndex({name:1});"
fi

cd $ORIG

#if [ ! -f "$download/geo-data/openstreetmap/england-latest.osm.pbf" ]; then
#  mkdir -p $download/geo-data/openstreetmap
#  cd $download/geo-data/openstreetmap
#  curl -C - -O http://download.geofabrik.de/europe/great-britain/england-latest.osm.pbf
#  OSMImport localhost geo_data_uk $download/geo-data/openstreetmap/england-latest.osm.pbf +RTS -K32M -RTS
#fi


