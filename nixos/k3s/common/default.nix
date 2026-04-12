{ self, ... }:
let
  prodOutputs = import "${self}/data/tf-output/prod.nix";
in
{
  flake.nixosModules.k3s-common =
    { lib, config, ... }:
    {
      services.k3s = {
        enable = true;

        nodeName = config.networking.hostName;
        role = lib.mkDefault "agent";

        gracefulNodeShutdown.enable = true;

        nodeIP = config.networking.ipv4;
        nodeExternalIP = config.networking.ipv4Public;

        serverAddr = lib.mkDefault "https://${prodOutputs.eevee_ip.value}:6443";
      };

      boot.kernelModules = [ "wireguard" ];
    };
}
