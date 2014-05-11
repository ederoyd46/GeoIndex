{ stdenv }:

stdenv.mkDerivation rec {
  name = "GeoIndex-0.0.0.1";

  src = . 
  
  makeFlags = "PREFIX=$(out)";

  enableParallelBuilding = true;

  meta = {
    homepage = https://github.com/ederoyd46/GeoIndex 
    description = "This application builds an index on the filesystem for fast access to GEO data";
    license = "BSD";
    platforms = stdenv.lib.platforms.unix;
  };
}
