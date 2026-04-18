{
  flake.nixosModules.boot =
    { config, modulesPath, ... }:
    {
      imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

      boot.growPartition = true;
      boot.loader.systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      boot.loader.efi.canTouchEfiVariables = true;

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
