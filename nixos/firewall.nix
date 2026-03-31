{
  flake.nixosModules.common = {
    networking.nftables.enable = true;

    networking.firewall.allowedTCPPorts = [
      ## k3s-agent-agent
      # flannel vxlan
      8472
      # kubelet metrics
      10250

      # https
      443
      # chall-https
      1337
      # chall-tls
      31337
    ];
  };
}
