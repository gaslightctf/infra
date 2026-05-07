{ lib, ... }:
{
  instances.rayquaza.extraConfig = {
    machine_type = lib.mkOverride 40 "e2-standard-2";
  };

  instances.kyogre.enable = lib.mkForce false;
  instances.groudon.enable = lib.mkForce false;
}
