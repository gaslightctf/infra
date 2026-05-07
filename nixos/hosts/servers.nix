{ self, lib, ... }:
{
  flake.nixosModules.rayquaza = {
    imports = [ self.nixosModules.k3s-server ];

    # rayquaza is the master
    services.k3s.clusterInit = true;
    services.k3s.serverAddr = lib.mkForce "";
  };

  flake.nixosModules.kyogre = {
    imports = [ self.nixosModules.k3s-server ];
  };
  flake.nixosModules.groudon = {
    imports = [ self.nixosModules.k3s-server ];
  };
}
