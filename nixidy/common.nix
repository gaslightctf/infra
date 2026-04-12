{ self, ... }:
{
  flake.modules.nixidy.common = {
    imports = [ self.modules.nixidy.nginx ];

    nixidy.target = {
      repository = "https://github.com/gaslightctf/infra.git";
      branch = "master";

      # overriden in dev.nix
      rootPath = "./manifests/prod";
    };
  };
}
