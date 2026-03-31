{ self, ... }:
let
  devOutputs = import "${self}/data/tf-output/dev.nix";
in
{
  flake.nixosModules.dev = {
    services.k3s = {
      serverAddr = "https://${devOutputs.eevee_ip.value}:6443";
    };
  };
}
