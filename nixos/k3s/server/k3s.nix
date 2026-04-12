{
  flake.nixosModules.k3s-server = {
    services.k3s = {
      role = "server";

      extraFlags = [
        # flannel vxlan does weird things with iptables that don't work well with the firewall
        "--flannel-backend=wireguard-native"
      ];
    };
  };
}
