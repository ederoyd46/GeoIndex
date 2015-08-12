let
  pkgs = import <nixpkgs> {};
  haskellEnv = pkgs.haskellPackages_ghc783_profiling.ghcWithPackages (self : (
    [
      self.protobuf
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
