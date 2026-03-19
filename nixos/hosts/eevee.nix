{ inputs, ... }:
{
  flake.nixosModules.eevee = {
    imports = [
      inputs.srvos.nixosModules.mixins-nginx
    ];

    boot.kernelParams = [
      "console=ttyS0,115200"
      "console=tty1"
    ];
  };
}
