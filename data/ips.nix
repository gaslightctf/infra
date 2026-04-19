{
  pallet-town-cidr = "10.6.7.0/24";
  pod-cidr = "10.67.0.0/16";

  instances = {
    eevee = {
      local = "10.6.7.10";
      pod-cidr = "10.67.10.0/24";
    };

    vaporeon = {
      local = "10.6.7.11";
      pod-cidr = "10.67.11.0/24";
    };

    jolteon = {
      local = "10.6.7.12";
      pod-cidr = "10.67.12.0/24";
    };
  };
}
