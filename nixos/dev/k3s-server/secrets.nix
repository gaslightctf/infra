{ self, ... }:
{
  flake.nixosModules.dev =
    { lib, config, ... }:
    {
      serverKeysAssertion =
        let
          keys = import "${self}/data/keys.nix";
          pred = k: k == keys.dev.${config.networking.hostName};
        in
        lib.any pred keys.devServers;
    };
}
