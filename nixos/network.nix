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

        # TODO: is this actually necessary?
        wireguard.enable = true;

        firewall = {
          enable = lib.mkForce false;

          checkReversePath = false;
        };
      };
    };
}
