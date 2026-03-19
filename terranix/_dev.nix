{ lib, ... }:
{
  custom.instanceExtra = {
    machine_type = lib.mkForce "e2-medium";
  };
}
