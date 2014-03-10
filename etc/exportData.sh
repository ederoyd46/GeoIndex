#!/bin/bash
mongoexport -d geo_data -c Location_Index -f searchTerm,latitude,longitude,source,rank,type,tags > /var/development/geodata.json
