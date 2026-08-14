{ lib, ... }:
{
  instances.rayquaza.extraConfig = {
    # TODO: t2d cpu limit
    # machine_type = lib.mkOverride 40 "t2d-standard-16";
    boot_disk.initialize_params.size = lib.mkOverride 40 100;
  };
}
