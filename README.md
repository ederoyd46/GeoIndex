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

*geo-index*<br>
usage: fileToIndex indexFile<br>
example: geo-index geodata.json geodata.idx

*geo-search*<br>
usage: indexFile term<br>
example: geo-search geodata.idx 'LEEDS'

*geo-server*<br>
usage: indexFile<br>
example: geo-server geodata.idx
