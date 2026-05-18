{
  flake.nixosModules.k3s-common =
    { config, ... }:
    {
      sops.secrets.k3s-token = {
        restartUnits = [ config.systemd.services.k3s.name ];
        sopsFile = config.sops.sharedSopsFile;
      };
      sops.secrets.k3s-registries = {
        restartUnits = [ config.systemd.services.k3s.name ];
        sopsFile = "${config.sops.secretsDir}/shared_registries.yaml";
        path = "/etc/rancher/k3s/registries.yaml";
        key = "";
      };
      sops.secrets.k3s-node-password = {
        restartUnits = [ config.systemd.services.k3s.name ];
        path = "/etc/rancher/node/password";
      };

      services.k3s = {
        tokenFile = config.sops.secrets.k3s-token.path;
      };

      systemd.services.k3s.wants = [ config.systemd.services.sops-install-secrets.name ];
    };
}
