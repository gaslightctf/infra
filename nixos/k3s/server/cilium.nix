{ self, ... }:
let
  ips = import "${self}/data/ips.nix";
in
{
  flake.nixosModules.k3s-server = {
    services.k3s = {
      extraFlags = [
        # all replaced by cilium
        "--flannel-backend=none"
        "--disable-network-policy"
        "--disable-kube-proxy"
        "--disable=servicelb"
        "--disable=traefik"

        "--cluster-cidr=${ips.pod-cidr}"
        # we will do it ourself
        "--kube-controller-manager-arg=allocate-node-cidrs=false"
      ];
    };
  };
}
