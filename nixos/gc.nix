{
  flake.nixosModules.common = {
    systemd.coredump.settings.Coredump = {
      Storage = "none";
      ProcessSizeMax = 0;
    };
    services.journald.extraConfig = "SystemMaxUse=250M";

    nix.gc = {
      automatic = true;
      dates = "weekly";
    };
  };
}
