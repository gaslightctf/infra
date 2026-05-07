{ self, ... }:
let
  ips = import "${self}/data/ips.nix";
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

        ## WARN: nodeIP and/or nodeExternalIP breaks networking for some reason!!

        # nodeIP = config.networking.ipv4;
        # nodeExternalIP = config.networking.ipv4Public;

        serverAddr = lib.mkDefault "https://${ips.instances.rayquaza.local}:6443";
      };
    };
}
