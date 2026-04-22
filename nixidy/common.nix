{ self, ... }:
{
  flake.modules.nixidy.common = {
    imports = [
      self.modules.nixidy.cilium
      self.modules.nixidy.traefik
      self.modules.nixidy.cert-manager

      self.modules.nixidy.cnpg
      self.modules.nixidy.berg
    ];

    nixidy.target = {
      repository = "https://github.com/gaslightctf/infra.git";
      branch = "master";

      # overriden in dev.nix
      rootPath = "./manifests/prod";
    };
  };
}
