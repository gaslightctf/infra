{ lib, ... }:
{
  instances.rayquaza.extraConfig = {
    machine_type = lib.mkOverride 40 "e2-standard-2";
  };
}
