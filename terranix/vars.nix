{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options = {
    vars = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            ephemeral = mkOption {
              type = types.bool;
              default = false;
            };

            type = mkOption {
              type = types.str;
              default = "string";
            };
          };
        }
      );
    };
  };

  config = {
    variable = builtins.mapAttrs (n: v:
      assert lib.assertMsg (builtins.match "^[a-zA-Z_][a-zA-Z0-9_]*$" n != null)
      "vars.<name> must be a valid Bash identifier (got: '${n}')"; {
        inherit (v) ephemeral type;
        sensitive = true;
      })
    config.vars;
  };
}
