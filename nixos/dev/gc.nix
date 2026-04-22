{
  flake.nixosModules.dev =
    { lib, pkgs, ... }:
    {
      services.journald.extraConfig = lib.mkForce "SystemMaxUse=50M";

      nix.gc.dates = lib.mkForce "hourly";

      environment.systemPackages = [ pkgs.ncdu ];
    };
}
