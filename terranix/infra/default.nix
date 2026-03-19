{
  imports = [
    ./network.nix
    ./network-lb.nix
  ];

  instances.eevee = {
    enable = true;
    tags = [ "server" ];
  };

  instances.vaporeon.enable = true;
  instances.jolteon.enable = true;
}
