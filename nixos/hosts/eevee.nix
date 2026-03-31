{ self, lib, ... }:
{
  flake.nixosModules.eevee = {
    imports = [
      self.nixosModules.k3s-server
    ];

    # eevee is the master
    services.k3s.clusterInit = true;
    services.k3s.serverAddr = lib.mkForce "";
  };
}
