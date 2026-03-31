{
  flake.nixosModules.k3s-common =
    { config, ... }:
    {
      sops.secrets.k3s-token.sopsFile = config.sops.sharedSopsFile;
      sops.secrets.k3s-node-password.path = "/etc/rancher/node/password";

      services.k3s = {
        tokenFile = config.sops.secrets.k3s-token.path;
      };
    };
}
