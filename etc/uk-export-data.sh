#!/bin/bash
mongoexport -d geo_data_uk -c Location_Index -f searchTerm,latitude,longitude,source,rank,type,tags > /var/development/geodata_uk.json