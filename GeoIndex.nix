let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
  fetchurl = pkgs.fetchurl;
  haskellEnv = pkgs.haskellPackages_ghc763_no_profiling.ghcWithPackages (self : (
    [
      self.protocolBuffers
      self.protocolBuffersDescriptor
      self.utf8String
      self.binary
      self.aeson
      self.hasktags
    ]
  ));
  version = "1.0.0.0";
  mainSrc = fetchurl {
    url = "https://github.com/ederoyd46/GeoIndex/archive/${version}.tar.gz";
    sha256 = null;
  };
in 

stdenv.mkDerivation rec {
  name = "GeoIndex-${version}";
  src = mainSrc;

  buildPhase = ''
    export PATH=${haskellEnv.outPath}/bin:$PATH
    make
  '';

  # Not needed - here for future reference
  buildDepends = [
    haskellEnv
  ];

  installPhase = ''
    ensureDir $out/bin
    cp -r ./bin $out
  '';

  meta = {
    description = "Builds an index based on Open Street Map data";
    homepage    = https://github.com/ederoyd46/GeoIndex;
    license     = stdenv.lib.licenses.mit;
    platforms   = stdenv.lib.platforms.all;
    maintainers = with stdenv.lib.maintainers; [ ederoyd46 ];
  };
}
 
