let
  pkgs = import <nixpkgs> {};
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
in 
  pkgs.myEnvFun {
    name = "geo-index-env";
    buildInputs = with pkgs; [
      haskellEnv
    ];
  }
