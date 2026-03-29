let
  keys = import ../data/keys.nix;

  admins = keys.users.sportshead.ssh;
in
{
  flake.nixosModules.common = {
    users.users.root.openssh.authorizedKeys.keys = admins;
  };
}
