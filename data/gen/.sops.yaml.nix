let
  keys = import ../keys.nix;

  admins = [keys.users.sportshead.age];
in {
  creation_rules = [
    {
      path_regex = "secrets/tf/.+\.(yaml|json|env)$";
      key_groups = [{age = admins;}];
    }

    {
      key_groups = [{age = admins;}];
    }
  ];
}
