print("Dropping Existing Search Terms");
db.Location_Index.drop();

/**
print("Building PostalCode Terms");
var postalCodes = db.PostalCode.find({"latitude":{$ne:""}, "longitude":{$ne:""}});
postalCodes.forEach(function(r) {
  var newRecord = { searchTerm: r.postalCode
                  , latitude: r.latitude
                  , longitude: r.longitude
                  , source: "GEONAMES-POSTCODE"
                  , rank: 200
                  };
  db.Location_Index.save(newRecord);
});
*/

print("Building Node Place Initial Terms");
var nodePlace = db.node.find({"tags.place": {$exists: true}, "tags.name": {$exists: true}});
nodePlace.forEach(function(entry) {
  if (entry.tags.place != "") {
    var rankType = entry.tags.place.trim().toUpperCase()
    var record = {   searchTerm: entry.tags.name
                   , latitude: entry.latitude
                   , longitude: entry.longitude
                   , source: "OPENSTREETMAP-NODE-PLACES"
                   , rank: findRank(rankType)
                   , type: rankType
                   , tags: entry.tags
                 }
    db.Location_Index.save(record);
  }
}); 

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

// function parseTerm(searchTerm) {
//   var parsedTerm = searchTerm.replace(/ near /g,'');
//   parsedTerm = parsedTerm.replace(/ in /g,'');
//   parsedTerm = parsedTerm.replace(/_/g,'');
//   parsedTerm = parsedTerm.replace(/[^\w]/g,'').toUpperCase()
//   return parsedTerm;
// }

// function fixTags(tags) {
//   for (var key in tags) { 
//     if (key.indexOf(".") > -1) {
//       delete tags[key];
//     }
//   }
//   return tags;
// }

