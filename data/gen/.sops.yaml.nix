let
  keys = import ../keys.nix;
in {
  creation_rules = [
    {
      path_regex = "secrets/.+\.(yaml|json|env)$";
      key_groups = [
        {
          age = [keys.users.sportshead.age];
        }
      ];
    }
  ];
}
