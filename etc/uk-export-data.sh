#!/bin/bash
mongoexport -d geo_data -c Location_Index -f term,latitude,longitude,source,rank,type,tags > /var/development/geodata_uk.json
