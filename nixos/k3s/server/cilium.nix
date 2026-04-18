{
  flake.nixosModules.k3s-server = {
    services.k3s = {
      extraFlags = [
        "--flannel-backend=none"
        "--disable-network-policy"
        "--disable-kube-proxy"
      ];
    };
  };
}
