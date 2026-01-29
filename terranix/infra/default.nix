{
  imports = [
    ./network.nix
  ];

  instances.eevee = {
    enable = true;
    tags = ["server"];
  };

  instances.vaporeon.enable = true;
  instances.jolteon.enable = true;
}
