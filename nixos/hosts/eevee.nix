{ inputs, ... }:
{
  flake.nixosModules.eevee = {
    imports = [
      inputs.srvos.nixosModules.mixins-nginx
    ];
  };
}
