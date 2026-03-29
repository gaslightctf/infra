{
  self,
  lib,
  inputs,
  ...
}:
let
  INSTANCE-OUTPUT-SUFFIX = "_ip_public";
  getInstances =
    xs:
    map (lib.removeSuffix INSTANCE-OUTPUT-SUFFIX)
    <| builtins.filter (lib.hasSuffix INSTANCE-OUTPUT-SUFFIX)
    <| builtins.attrNames xs;

  devOutputs = import ../data/tf-output/dev.nix;
  devInstances = getInstances devOutputs;

  prodOutputs = import ../data/tf-output/prod.nix;
  prodInstances = getInstances prodOutputs;
in
{
  flake.colmena =
    builtins.listToAttrs
    <|
      (map (n: {
        name = "dev-${n}";
        value = {
          deployment = {
            targetHost = devOutputs."${n}${INSTANCE-OUTPUT-SUFFIX}".value;
            tags = [ "dev" ];
          };

          imports = [
            self.nixosModules.common
            (self.nixosModules.${n} or { })
          ];
        };
      }) devInstances)
      ++ (map (n: {
        name = "prod-${n}";
        value = {
          deployment = {
            targetHost = prodOutputs."${n}${INSTANCE-OUTPUT-SUFFIX}".value;
            tags = [ "prod" ];
          };

          imports = [
            self.nixosModules.common
            (self.nixosModules.${n} or { })
          ];
        };
      }) prodInstances);

  flake.nixosConfigurations =
    let
      inherit (inputs.nixpkgs.lib) nixosSystem;
    in
    builtins.listToAttrs
    <|
      (map (n: {
        name = "dev-${n}";
        value = nixosSystem {
          modules = [
            self.nixosModules.common
            (self.nixosModules.${n} or { })
          ];
        };
      }) devInstances)
      ++ (map (n: {
        name = "prod-${n}";
        value = nixosSystem {
          modules = [
            self.nixosModules.common
            (self.nixosModules.${n} or { })
          ];
        };
      }) prodInstances);
}
