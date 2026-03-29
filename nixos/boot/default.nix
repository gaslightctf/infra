{
  flake.nixosModules.boot =
    { modulesPath, ... }:
    {
      imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

      boot.growPartition = true;
      boot.loader.grub.devices = [ "/dev/sda" ];
      boot.loader.grub.configurationLimit = 3;
      boot.loader.grub.extraConfig = ''
        serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
        terminal_input serial
        terminal_output serial
      '';

      fileSystems."/" = {
        device = "/dev/disk/by-label/root";
        fsType = "ext4";
        autoResize = true;
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
