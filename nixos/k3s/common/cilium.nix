{
  flake.nixosModules.k3s-common =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.cilium-cli ];
      services.k3s = {
        nodeTaint = [
          "node.cilium.io/agent-not-ready:NoExecute"
        ];
      };

      # stolen from https://git.sr.ht/~goorzhel/nixos/tree/78aece90f3ed319dc73b02b9f83d646bd0e8f2db/item/profiles/k3s/common/net.nix
      boot.kernelModules = [
        # cilium-1.15.2/pkg/datapath/iptables/iptables.go:354
        "xt_socket"

        "wireguard"
      ];

      # also stolen from https://git.sr.ht/~goorzhel/nixos/tree/78aece90f3ed319dc73b02b9f83d646bd0e8f2db/item/profiles/k3s/common/net.nix
      networking = {
        dhcpcd.denyInterfaces = [
          "lxc*"
          "cilium*"
        ];

        # https://docs.cilium.io/en/stable/security/network/encryption-wireguard/
        wireguard.enable = true;

        # k3s: https://github.com/k3s-io/docs/blob/4d9c6a98365e5c5ce1564f2292aa8a277f6c0a2f/docs/installation/requirements.md?plain=1#L40-L64
        # Cilium: https://docs.cilium.io/en/stable/operations/system_requirements/#firewall-requirements
        firewall = {
          allowedTCPPorts = [
            80 # HTTP ingress
            443 # HTTPS ingress
            4240 # Cilium health checks
            4244 # Hubble
            5001 # k3s' embedded Spegel
            6443 # k3s supervisor; k8s API
            # 7946 # MetalLB
            # 9100 # Prometheus Node Exporter
            9962 # cilium-agent metrics
            9963 # cilium-operator metrics
            10250 # kubelet metrics

            # k3s embedded etcd
            2379
            2380
          ];
          allowedUDPPorts = [
            8472 # Cilium VXLAN
            51871 # Cilium WireGuard
          ];

          # Reverse-path filtering is discouraged by Cilium.
          # cilium-1.15.2/pkg/datapath/loader/base.go:365
          checkReversePath = false;
        };
      };
    };
}
