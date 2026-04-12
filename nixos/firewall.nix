{
  flake.nixosModules.common = {
    networking.firewall.allowedTCPPorts = [
      ## k3s-agent-agent
      # kubelet metrics + API
      10250

      # https
      443
      # chall-https
      1337
      # chall-tls
      31337
    ];

    networking.firewall.allowedUDPPorts = [
      ## k3s-agent-agent
      # flannel wireguard
      51820
    ];
  };
}
