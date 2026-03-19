{ lib, ... }:
{
  custom.instance_extra = {
    machine_type = lib.mkForce "e2-medium";
  };
}
