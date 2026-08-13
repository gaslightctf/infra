{
  flake.nixosModules.common =
    { lib, ... }:
    {
      boot.kernelModules = [
        "xt_socket"
        "wireguard"
      ];

      networking = {
        dhcpcd.denyInterfaces = [
          "lxc*"
          "cilium*"
        ];

        wireguard.enable = true;

        firewall = {
          enable = lib.mkForce false;

          checkReversePath = false;
        };
      };
    };
}
