{ self, ... }:
{
  flake.modules.nixidy.common = {
    imports = [ self.modules.nixidy.http-echo ];

    nixidy.target = {
      repository = "https://github.com/gaslightctf/infra.git";
      branch = "master";

      # overriden in dev.nix
      rootPath = "./manifests/prod";
    };
  };
}
