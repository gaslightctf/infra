{ inputs, self, ... }:
{
  flake.nixosModules.common = {
    imports = [
      inputs.srvos.nixosModules.server
      inputs.srvos.nixosModules.mixins-trusted-nix-caches

      self.nixosModules.sops
      self.nixosModules.boot
    ];

    system.stateVersion = "26.05";

    nixpkgs.hostPlatform = "x86_64-linux";

    # https://github.com/NuschtOS/nixos-modules/blob/753e2d83eee3d259f9c7ab8cdc1933766d4761a5/modules/users.nix
    environment.interactiveShellInit = /* sh */ ''
      # raise some awareness towards failed services
      systemctl --failed --full --no-pager --quiet || true
      if [[ -v DBUS_SESSION_BUS_ADDRESS ]]; then
        systemctl --failed --full --no-pager --user --quiet || true
      fi
    '';
  };
}
