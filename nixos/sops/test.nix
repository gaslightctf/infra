{
  flake.nixosModules.sops =
    { config, ... }:
    {
      sops.secrets.my-name = { };
      sops.secrets.hello-shared.sopsFile = config.sops.sharedSopsFile;
    };
}
