{
  flake.nixosModules.common = {
    services.journald.console = "/dev/ttyS0";
  };
}
