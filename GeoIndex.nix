let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
  fetchurl = pkgs.fetchurl;
  fetchgit = pkgs.fetchgit;
  haskellEnv = pkgs.haskellPackages_ghc783_profiling.ghcWithPackages (self : (
    [
      self.protobuf
      self.utf8String
      self.binary
      self.aeson
      self.hasktags
    ]
  ));
  version = "1.0.0.1";
  gitSrc = fetchgit {
    url = "https://github.com/ederoyd46/GeoIndex";
    rev = "97848552899d0fd0856a9ddb265038b61a8a9261";
    sha256 = "1vnqh5jhlpdkd4083ccl2y9jz89m13ch43zyfb56p0k60p91rcrg";
  };

in 

stdenv.mkDerivation rec {
  name = "GeoIndex-${version}";
  src = gitSrc;

  buildPhase = ''
    export PATH=${haskellEnv.outPath}/bin:$PATH
    make
  '';

  # Not needed - here for future reference
  buildDepends = [
    haskellEnv
  ];

  installPhase = ''
    mkdir -p $out/bin
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
 
