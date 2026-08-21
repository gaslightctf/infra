{ lib, ... }:
{
  instances.rayquaza.extraConfig = {
    machine_type = lib.mkOverride 40 "e2-highmem-2";
    boot_disk.initialize_params.size = lib.mkOverride 40 100;
  };
}
