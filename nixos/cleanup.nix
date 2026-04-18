{
  flake.nixosModules.common = {
    systemd.services.cleanup-old-root = {
      description = "Remove /old-root if it exists";
      wantedBy = [ "local-fs.target" ];
      after = [ "local-fs.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/bin/sh -c 'if [ -d /old-root ]; then rm -rf /old-root; fi'";
      };
    };
  };
}
