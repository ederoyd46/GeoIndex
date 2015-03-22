Description
-----------

This application uses data imported by the https://github.com/ederoyd46/OSMImport project to build an index on the filesystem for fast access by client applications. It is also the goal of this project to create a library for other applications to link against.


Current Status
--------------

0.0.0.1 - Initial version, scripts to export data from mongo then build the index. Sample client applications for searching.

Installation Instructions
-------------------------

1. If working with cabal 1.18 you can run this in a sandbox by calling 'make sandbox-init'
2. Run 'make install' to compile and install into your sandbox.
3. Extract data from mongo in the correct format by running './etc/exportData.sh' (you will need to change this script to suite your own mongodb installation).


Usage
-----

There are three client applications to build and search the index;

*geo-index*

```
usage: fileToIndex indexFile
example: geo-index geodata.json geodata.idx
```

*geo-search*

```
usage: indexFile term
example: geo-search geodata.idx leeds
```

*geo-server*

```
usage: indexFile
example: geo-server geodata.idx
```

Docker Usage
------------

Pull down the repository

```
docker pull ederoyd46/geoindex
```

Run a place name search

```
docker run --rm=true ederoyd46/geoindex leeds
```

Run a post code search

```
docker run --rm=true ederoyd46/geoindex "LS1 3AD"
```

Run in server mode

```
docker run --rm=true --publish=8001:8001 --entrypoint="geo-server" ederoyd46/geoindex /data/geodata_uk.idx -p 8001 --access-log=/var/log/access.log --error-log=/var/log/error.log
```

Alternative server mode using the DE index

```
docker run --rm=true --publish=8002:8002 --entrypoint="geo-server" ederoyd46/geoindex /data/geodata_de.idx -p 8002 --access-log=/var/log/access.log --error-log=/var/log/error.log
```


Run a query in a browser example, return as JSON

```
http://www.ederoyd.co.uk:8001/search/london
```

```
http://www.ederoyd.co.uk:8001/search/ls13ad
```

```
http://www.ederoyd.co.uk:8002/search/berlin
```

```
http://www.ederoyd.co.uk:8002/search/40210
```


Run a query in a browser example, return as text

```
http://www.ederoyd.co.uk:8001/search/london/txt
```

```
http://www.ederoyd.co.uk:8002/search/berlin/txt
```
