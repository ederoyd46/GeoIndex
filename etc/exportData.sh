#!/bin/bash
mongoexport --csv -d geo_data -c Location_Index -f searchTerm,latitude,longitude,source > /var/development/geodata.csv
