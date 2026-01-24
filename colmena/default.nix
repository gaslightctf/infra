{
  colmena,
  nixpkgs,
  srvos,
  ...
}: {
  flake.colmenaHive = {
    meta = {
      nixpkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    };

    default = {
      imports = [srvos.nixosModules.server srvos.nixosModules.mixins-trusted-nix-caches];
    };

    eevee = {
      imports = [srvos.nixosModules.mixins-nginx];
    };
  };
}
