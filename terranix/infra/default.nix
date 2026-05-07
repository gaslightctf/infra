{ lib, ... }:
{
  instances.rayquaza = {
    enable = true;
    tags = [ "server" ];
    extraConfig = {
      machine_type = lib.mkOverride 40 "e2-standard-2";
    };
  };
  instances.kyogre = {
    enable = true;
    tags = [ "server" ];
    extraConfig = {
      machine_type = lib.mkOverride 40 "e2-standard-2";
    };
  };
  instances.groudon = {
    enable = true;
    tags = [ "server" ];
    extraConfig = {
      machine_type = lib.mkOverride 40 "e2-standard-2";
    };
  };
}
