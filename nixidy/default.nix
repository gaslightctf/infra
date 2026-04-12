{
  self,
  inputs,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (inputs) nixidy;
in
{
  imports = [
    (flake-parts-lib.mkTransposedPerSystemModule {
      name = "nixidyEnvs";
      option = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
      };
      file = ./default.nix;
    })
  ];

  perSystem =
    { pkgs, ... }:
    {
      nixidyEnvs = nixidy.lib.mkEnvs {
        inherit pkgs;

        envs = {
          dev.modules = [
            self.modules.nixidy.common
            self.modules.nixidy.dev
          ];
          prod.modules = [
            self.modules.nixidy.common
          ];
        };
      };
    };
}
