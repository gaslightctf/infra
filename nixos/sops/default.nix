{
  inputs,
  self,
  lib,
  ...
}:
{
  flake.nixosModules.sops =
    { config, ... }:
    let
      defaultSopsFile = "${config.sops.secretsDir}/${config.networking.hostName}.yaml";
    in
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];

      options = {
        sops.secretsDir = lib.mkOption {
          type = lib.types.str;
          default = "${self}/secrets/prod";
        };
        sops.sharedSopsFile = lib.mkOption {
          type = lib.types.str;
          default = "${config.sops.secretsDir}/shared.yaml";
        };
      };

      config = {
        sops.defaultSopsFile = lib.mkIf (builtins.pathExists defaultSopsFile) defaultSopsFile;

        sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };
}
