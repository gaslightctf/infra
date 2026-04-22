{
  flake.nixosModules.common = {
    systemd.coredump.extraConfig = ''
      Storage=None
      ProcessSizeMax=0
    '';
    services.journald.extraConfig = "SystemMaxUse=250M";

    nix.gc = {
      automatic = true;
      dates = "weekly";
    };
  };
}
