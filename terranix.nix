{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      config,
      inputs',
      lib,
      ...
    }:
    let
      inherit (inputs'.tf-providers.legacyPackages) providers;

      cfg = config.terranix.terranixConfigurations;

      tofu = pkgs.opentofu.withPlugins (_: [
        providers.hashicorp.google
        providers.cloudflare.cloudflare
      ]);

      sopsToEnv =
        secretFile:
        # bash
        ''
          # shellcheck source=/dev/null
          source <(
            ${pkgs.sops}/bin/sops decrypt ${secretFile} |
            ${pkgs.yq}/bin/yq -r 'to_entries | .[] | "export \(.key)=\(.value | @sh)"'
          )
        '';
    in
    {
      terranix = {
        exportDevShells = false;

        terranixConfigurations.prod = {
          terraformWrapper = {
            package = tofu;
            prefixText =
              # bash
              ''
                ${sopsToEnv ./secrets/tf/prod.yaml}

                ln -sf ${cfg.prod.result.terraformConfiguration} ${cfg.prod.workdir}/config.tf.json
              '';
          };
          workdir = "\"$PRJ_ROOT\"/.tf/prod";
          modules = [
            (inputs.import-tree ./terranix)
          ];
          # TODO: use flake.parts
          extraArgs = {
            inherit providers;
          };
        };

        terranixConfigurations.dev = {
          terraformWrapper = {
            package = tofu;
            prefixText =
              # bash
              ''
                ${sopsToEnv ./secrets/tf/dev.yaml}

                ln -sf ${cfg.dev.result.terraformConfiguration} ${cfg.dev.workdir}/config.tf.json
              '';
          };
          workdir = "\"$PRJ_ROOT\"/.tf/dev";
          modules = [
            (inputs.import-tree ./terranix)
            ./terranix/_dev.nix
          ];
          # TODO: use flake.parts
          extraArgs = {
            inherit providers;
          };
        };
      };

      apps = builtins.listToAttrs (
        map
          (
            env:
            let
              wrapper = cfg.${env}.result.terraformWrapper;
            in
            {
              name = env;
              value = {
                type = "app";
                program = "${wrapper}/bin/${wrapper.meta.mainProgram}";
              };
            }
          )
          [
            "prod"
            "dev"
          ]
      );
    };
}
