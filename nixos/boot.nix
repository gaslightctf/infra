{
  flake.nixosModules.common = {
    boot.growPartition = true;
    boot.loader.grub.devices = [ "/dev/sda" ];

    fileSystems."/" = {
      device = "/dev/sda";
      fsType = "ext4";
    };

    srvos.boot.consoles = [ ];
    services.journald.console = "/dev/ttyS0";

    boot.kernelParams = [
      "console=ttyS0"
      "panic=1"
      "boot.panic_on_fail"
    ];
    boot.initrd.kernelModules = [ "virtio_scsi" ];
    boot.kernelModules = [
      "virtio_pci"
      "virtio_net"
    ];
  };
}
