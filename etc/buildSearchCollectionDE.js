print("Dropping Existing Search Terms");
db.Location_Index.drop();

// print("Building Postal Code Terms");
// var nodePlace = db.node.find({"tags.postal_code": {$exists: true});
// nodePlace.forEach(function(entry) {
//   if (entry.tags.place != "") {
//     var rankType = entry.tags.place.trim().toUpperCase()
//     var record = {   term: entry.tags.name
//                    , latitude: entry.latitude
//                    , longitude: entry.longitude
//                    , source: "OPENSTREETMAP-NODE-PLACES"
//                    , rank: findRank(rankType)
//                    , type: rankType
//                    , tags: entry.tags
//                  }
//     db.Location_Index.save(record);
//   }
// });


print("Building Address Postal Code Terms");
var nodePlace = db.node.find({"tags.addr:postcode": {$exists: true}});
nodePlace.forEach(function(entry) {
  var record = {   term: entry.tags['addr:postcode']
                 , latitude: entry.latitude
                 , longitude: entry.longitude
                 , source: "OPENSTREETMAP-NODE-PLACES"
                 , rank: 200
                 , type: "POSTCODE"
                 , tags: entry.tags
               }
  db.Location_Index.save(record);
});

print("Building Node Place Initial Terms");
var nodePlace = db.node.find({"tags.place": {$exists: true}, "tags.name": {$exists: true}});
nodePlace.forEach(function(entry) {
  if (entry.tags.place != "") {
    var rankType = entry.tags.place.trim().toUpperCase()
    var record = {   term: entry.tags.name
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
