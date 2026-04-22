{ self, ... }:
{
  # load option for all nodes
  flake.nixosModules.k3s-common =
    { lib, config, ... }:
    {
      options.serverKeysAssertion = lib.mkOption {
        default =
          let
            keys = import "${self}/data/keys.nix";
            pred = k: k == keys.prod.${config.networking.hostName};
          in
          lib.any pred keys.prodServers;

        type = lib.types.bool;
      };
    };

  flake.nixosModules.k3s-server =
    { lib, config, ... }:
    let
      secrets =
        builtins.readDir "${config.sops.secretsDir}/k8s"
        |> lib.filterAttrs (_: v: v == "regular")
        |> lib.mapAttrs' (
          n: _: {
            name = "k8s-${n}";
            value = {
              format = "yaml";
              sopsFile = "${config.sops.secretsDir}/k8s/${n}";
              key = "";
              # without a prefix, we end up with a traefik.yaml which gets yeeted by the controller (since --disable=traefik)
              path = "/var/lib/rancher/k3s/server/manifests/secrets/secret-${n}";
            };
          }
        );
    in
    {
      config = {
        assertions = [
          {
            assertion = config.serverKeysAssertion;
            message = "Host ${config.networking.hostName} is not in servers keylist! check data/keys.nix";
          }
        ];

        services.k3s = {
          extraFlags = [
            "--secrets-encryption"
          ];
        };

        sops.secrets = secrets;
      };
    };
}
