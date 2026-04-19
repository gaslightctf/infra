{
  self,
  lib,
  inputs,
  ...
}:
let
  ips = import ../data/ips.nix;

  IP_PUBLIC_OUTPUT_SUFFIX = "_ip_public";
  getInstances =
    xs:
    map (lib.removeSuffix IP_PUBLIC_OUTPUT_SUFFIX)
    <| builtins.filter (lib.hasSuffix IP_PUBLIC_OUTPUT_SUFFIX)
    <| builtins.attrNames xs;

  devOutputs = import ../data/tf-output/dev.nix;
  devInstances = getInstances devOutputs;

  prodOutputs = import ../data/tf-output/prod.nix;
  prodInstances = getInstances prodOutputs;

  mkNetworkingModule =
    outputs: n:
    (
      { lib, ... }:
      {
        options = {
          networking.ipv4 = lib.mkOption {
            type = lib.types.str;
            default = ips.instances.${n}.local;
          };
          networking.ipv4Public = lib.mkOption {
            type = lib.types.str;
            default = outputs."${n}${IP_PUBLIC_OUTPUT_SUFFIX}".value;
          };
        };
        config.networking.hostName = n;
      }
    );
in
{
  flake.colmena =
    builtins.listToAttrs
    <|
      (map (n: {
        name = "dev-${n}";
        value = {
          deployment = {
            targetHost = devOutputs."${n}${IP_PUBLIC_OUTPUT_SUFFIX}".value;
            tags = [ "dev" ];

            sshOptions = [
              "-F"
              "${self}/data/ssh/config"
            ];
          };

          imports = [
            self.nixosModules.common
            self.nixosModules.dev

            (self.nixosModules.${n} or { })
            (mkNetworkingModule devOutputs n)
          ];
        };
      }) devInstances)
      ++ (map (n: {
        name = "prod-${n}";
        value = {
          deployment = {
            targetHost = prodOutputs."${n}${IP_PUBLIC_OUTPUT_SUFFIX}".value;
            tags = [ "prod" ];

            sshOptions = [
              "-F"
              "${self}/data/ssh/config"
            ];
          };

          imports = [
            self.nixosModules.common

            (self.nixosModules.${n} or { })
            (mkNetworkingModule devOutputs n)
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
            self.nixosModules.dev

            (self.nixosModules.${n} or { })
            (mkNetworkingModule devOutputs n)
          ];
        };
      }) devInstances)
      ++ (map (n: {
        name = "prod-${n}";
        value = nixosSystem {
          modules = [
            self.nixosModules.common

            (self.nixosModules.${n} or { })
            (mkNetworkingModule devOutputs n)
          ];
        };
      }) prodInstances)
      # used for nixos-anywhere
      ++ [
        {
          name = "dev-base";
          value = nixosSystem {
            modules = [
              self.nixosModules.common
              self.nixosModules.dev
            ];
          };
        }
        {
          name = "prod-base";
          value = nixosSystem {
            modules = [
              self.nixosModules.common
            ];
          };
        }
      ];
}
