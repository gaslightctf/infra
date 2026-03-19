{
  self,
  lib,
  inputs,
  ...
}:
{
  flake = {
    options.colmena = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
    };

    config = {
      colmenaHive = inputs.colmena.lib.makeHive (
        self.colmena
        // {
          meta = {
            nixpkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
            };

            allowApplyAll = false;
          };
        }
      );
    };
  };
}
