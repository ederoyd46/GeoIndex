let
  pkgs = import <nixpkgs> {};
  haskellEnv = pkgs.haskellPackages_ghc763_no_profiling.ghcWithPackages (self : (
    [
      self.protocolBuffers
      self.protocolBuffersDescriptor
      self.utf8String
      self.binary
      self.aeson
    ]
  ));
in 
  pkgs.myEnvFun {
    name = "geo-index";
    buildInputs = with pkgs; [
      haskellEnv
    ];
  }


#     extraCmds = $(grep export ${hsEnv.outPath}/bin/ghc);


 # ++
 # Include the deps of our project to make them available for tools:
 #(geoIndexPkgs.callPackage ./my-haskell-project.nix {}).propagatedNativeBuildInputs));

#  let
#    pkgs = import <nixpkgs> {};
#    stdenv = pkgs.stdenv;
#  in rec {
#    clangEnv = stdenv.mkDerivation rec {
#      name = "clang-env";
#      version = "1.1.1.1";
#      src = ./.;
#      buildInputs = [ pkgs.clang ];
#    };
#  }