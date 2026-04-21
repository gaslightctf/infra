{
  palletTownCIDR = "10.6.7.0/24";
  podCIDR = "10.67.0.0/16";

  instances = {
    eevee = {
      local = "10.6.7.10";
      podCIDR = "10.67.10.0/24";
    };

    vaporeon = {
      local = "10.6.7.11";
      podCIDR = "10.67.11.0/24";
    };

    jolteon = {
      local = "10.6.7.12";
      podCIDR = "10.67.12.0/24";
    };
  };
}
