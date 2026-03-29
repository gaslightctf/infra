{ inputs, self, ... }:
{
  flake.nixosModules.common = {
    imports = [
      inputs.srvos.nixosModules.server
      inputs.srvos.nixosModules.mixins-trusted-nix-caches

      self.nixosModules.boot
    ];

    system.stateVersion = "26.05";

    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
