{ self, ... }:
{
  flake.nixosModules.dev = {
    sops.secretsDir = "${self}/secrets/dev";
  };
}
