{
  flake.nixosModules.dev =
    { lib, pkgs, ... }:
    {
      services.journald.extraConfig = lib.mkForce "SystemMaxUse=50M";

      environment.systemPackages = [ pkgs.ncdu ];
    };
}
