let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
  fetchurl = pkgs.fetchurl;
  fetchgit = pkgs.fetchgit;
  haskellEnv = pkgs.haskellPackages_ghc763.ghcWithPackages (self : (
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
  gitSrc = fetchgit {
    url = "https://github.com/ederoyd46/GeoIndex";
    rev = "355bec620397e2d8f614ca03ae3242f0c2dffe7c";
    sha256 = "1swwskv1z0h4fwiql8w7cf1vjfqf5nkzg7i7cdz0w14cw2352km9";
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
 
