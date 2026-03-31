{
  flake.nixosModules.k3s-server = {
    networking.firewall.allowedTCPPorts = [
      ## k3s-server-server
      # embedded etcd
      2379
      2380

      ## k3s-agent-server
      # k3s server
      6443
    ];
  };
}
