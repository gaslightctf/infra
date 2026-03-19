let
  mapAttrsToList = f: a: builtins.attrValues <| builtins.mapAttrs f a;

  keys = import ./keys.nix;

  admins = keys.users.sportshead.age;

  mkRules =
    env:
    (mapAttrsToList (
      hostname:
      { age, ... }:
      {
        path_regex = "secrets/${env}/${hostname}\\.(yaml|json|env)$";
        key_groups = [ { age = admins ++ [ age ]; } ];
      }
    ) keys.${env})
    ++ [
      {
        path_regex = "secrets/${env}/shared+\\.(yaml|json|env)$";
        key_groups = [
          {
            age = admins ++ mapAttrsToList (_: { age, ... }: age) keys.${env};
          }
        ];
      }
    ];
in
{
  creation_rules = builtins.concatLists [
    [
      {
        path_regex = "secrets/tf/.+\\.(yaml|json|env)$";
        key_groups = [ { age = admins; } ];
      }
    ]

    (mkRules "dev")
    (mkRules "prod")

    [
      {
        key_groups = [ { age = admins; } ];
      }
    ]
  ];
}
