let
  mapAttrsToList = f: a: builtins.attrValues <| builtins.mapAttrs f a;

  keys = import ../keys.nix;

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
        path_regex = "secrets/${env}/shared[\\w_]*\\.(yaml|json|env)$";
        key_groups = [
          {
            age = admins ++ mapAttrsToList (_: { age, ... }: age) keys.${env};
          }
        ];
      }
      {
        path_regex = "secrets/${env}/k8s/.+\\.yaml$";
        key_groups = [
          {
            age = admins ++ map ({ age, ... }: age) keys."${env}Servers";
          }
        ];

        unencrypted_regex = "^(apiVersion|kind|metadata|type|immutable)$";
      }
    ];

  sopsYAML = {
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
  };
in
{
  perSystem =
    { pkgs, ... }:
    {
      files.files = [
        {
          path_ = ".sops.yaml";
          drv = pkgs.writers.writeYAML ".sops.yaml" sopsYAML;
        }
      ];
    };
}
