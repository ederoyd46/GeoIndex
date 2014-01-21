function parseTerm(searchTerm) {
  var parsedTerm = searchTerm.replace(/ near /g,'');
  parsedTerm = parsedTerm.replace(/ in /g,'');
  parsedTerm = parsedTerm.replace(/_/g,'');
  parsedTerm = parsedTerm.replace(/[^\w]/g,'').toUpperCase()
  return parsedTerm;
}

function findRank(element) {
  if("CITY" == element) return 100;
  if("SUBURB" == element) return 90;
  if("TOWN" == element) return 80;
  if("VILLAGE" == element) return 70;
  if("HAMLET" == element) return 60;
  if("LOCALITY" == element) return 50;
  if("MOOR" == element) return 40;
  if("FARM" == element) return 30;
  return 10;
}

function fixTags(tags) {
  for (var key in tags) { 
    if (key.indexOf(".") > -1) {
      delete tags[key];
    }
  }
  return tags;
}

print("Dropping Existing Search Terms");
db.Location_Index.drop();


print("Building Node Place Initial Terms");
var nodePlace = db.node.find({"tags.place": {$exists: true}, "tags.name": {$exists: true}});
nodePlace.forEach(function(entry) {
  if (entry.tags.place != "") {
    var parsedSearchTerm = parseTerm(entry.tags.name);
    var parsedType = parseTerm(entry.tags.place);
    var record = {   latitude: entry.latitude
                   , longitude: entry.longitude
                   , location: [entry.longitude, entry.latitude]
                   , searchTerm: parsedSearchTerm
                   , type: parsedType
                   , rank: findRank(parsedType)
                   , source: "OPENSTREETMAP-NODE-PLACES"
                   , source_data: entry.tags
                 }

    db.Location_Index.save(record);
  }
}); 

print("Building PostalCode Terms");
print("We store location as longitude and latitude for the geo spatial index");
var postalCodes = db.PostalCode.find({"latitude":{$ne:""}, "longitude":{$ne:""}});
postalCodes.forEach(function(r) {
  var original = r.postalCode;
  var term = parseTerm(original);
  var newRecord = { searchTerm: term
                  , latitude: r.latitude
                  , longitude: r.longitude
                  , location: [parseFloat(r.longitude), parseFloat(r.latitude)]
                  , rank: 10
                  , source: "GEONAMES-POSTCODE"
                  , source_data: r
                  };
  db.Location_Index.save(newRecord);
});
