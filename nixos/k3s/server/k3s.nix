{
  flake.nixosModules.k3s-server = {
    services.k3s = {
      role = "server";

      extraFlags = [
        "--secrets-encryption"
      ];
    };
  };
}
