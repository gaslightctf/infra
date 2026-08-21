{ lib, ... }:
{
  instances.rayquaza.extraConfig = {
    machine_type = lib.mkOverride 40 "t2d-standard-4";
    boot_disk.initialize_params.size = lib.mkOverride 40 100;
  };
}
