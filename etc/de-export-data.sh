#!/bin/bash
mongoexport -d geo_data_de -c Location_Index -f term,latitude,longitude,source,rank,type,tags > ../test-data/geodata_de.json
