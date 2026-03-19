{
  flake.nixosModules.common = {
    boot.growPartition = true;
    boot.loader.grub.devices = [ "/dev/sda" ];

    fileSystems."/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };

    # networking.useNetworkd = true;
    # networking.useDHCP = false;
    #
    # services.qemuGuest.enable = true;
  };
}
