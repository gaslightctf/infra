{
  perSystem = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.terranix.terranixConfigurations;

    tofu = pkgs.opentofu.withPlugins (p: with p; [hashicorp_google]);

    sopsToEnv = secretFile:
    # bash
    ''
      # shellcheck source=/dev/null
      source <(
        ${pkgs.sops}/bin/sops decrypt ${secretFile} |
        ${pkgs.yq}/bin/yq -r 'to_entries | .[] | "export \(.key)=\"\(.value)\""'
      )
    '';
  in {
    terranix = {
      exportDevShells = false;

      terranixConfigurations.prod = {
        terraformWrapper = {
          package = tofu;
          prefixText =
            # bash
            ''
              ${sopsToEnv ./secrets/tf/backend.yaml}
              ${sopsToEnv ./secrets/tf/prod.yaml}

              ln -sf ${cfg.prod.result.terraformConfiguration} ${cfg.prod.workdir}/config.tf.json
            '';
        };
        workdir = "\"$PRJ_ROOT\"/.tf/prod";
        modules = [./terranix];
      };

      terranixConfigurations.dev = {
        terraformWrapper = {
          package = tofu;
          prefixText =
            # bash
            ''
              ${sopsToEnv ./secrets/tf/backend.yaml}
              ${sopsToEnv ./secrets/tf/dev.yaml}

              ln -sf ${cfg.dev.result.terraformConfiguration} ${cfg.dev.workdir}/config.tf.json
            '';
        };
        workdir = "\"$PRJ_ROOT\"/.tf/dev";
        modules = [./terranix ./terranix/dev.nix];
      };
    };

    apps = builtins.listToAttrs (builtins.map (env: let
      wrapper = cfg.${env}.result.terraformWrapper;
    in {
      name = env;
      value = {
        type = "app";
        program = "${wrapper}/bin/${wrapper.meta.mainProgram}";
      };
    }) ["prod" "dev"]);
  };
}
