{
  perSystem = {pkgs, ...}: let
    gen-sops-yaml = "${pkgs.nix}/bin/nix eval --json -f ./data/gen/.sops.yaml.nix | ${pkgs.yj}/bin/yj -jy";
  in {
    devshells.default = rec {
      name = "gaslightCTF infra";
      motd = ''
        {202}🔥 Welcome to ${name}{reset}
        $(type -p countdown &>/dev/null && countdown)
        $(type -p menu &>/dev/null && menu)
      '';

      commands = [
        {
          package = pkgs.age;
          category = "secrets";
        }
        {
          package = pkgs.sops;
          category = "secrets";
        }

        {
          package = pkgs.google-cloud-sdk;
          category = "cloud";
          name = "gcloud";
        }

        {
          name = "tofu-dev";
          help = "Run tofu with the dev config";
          category = "tofu";
          command = ''
            nix run .#dev -- $@
          '';
        }
        {
          name = "tofu-prod";
          help = "Run tofu with the prod config";
          category = "tofu";
          command = ''
            nix run .#prod -- $@
          '';
        }

        {
          package = pkgs.yq;
        }

        {
          name = "countdown";
          help = "Display countdown to gaslightCTF 2026";
          command = ''
            #!/bin/bash

            START_DATE="2026-08-21T12:00:00Z"
            END_DATE="2026-08-24T12:00:00Z"

            current_epoch=$(date +%s)
            start_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$START_DATE" +%s 2>/dev/null || date -d "$START_DATE" +%s)
            end_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$END_DATE" +%s 2>/dev/null || date -d "$END_DATE" +%s)

            if [ $current_epoch -lt $start_epoch ]; then
                diff=$((start_epoch - current_epoch))
                echo -n "gaslightCTF starts in: "
            else
                diff=$((end_epoch - current_epoch))
                if [ $diff -lt 0 ]; then
                    echo "gaslightCTF 2026 has ended!"
                    exit 0
                fi
                echo -n "gaslightCTF ends in: "
            fi

            days=$((diff / 86400))
            hours=$(((diff % 86400) / 3600))
            minutes=$(((diff % 3600) / 60 ))
            seconds=$((diff % 60))

            echo -e "\033[1;31m''${days}d ''${hours}h ''${minutes}m ''${seconds}s\033[0m"
          '';
        }

        {
          name = "gen-sops-yaml";
          help = "Generate the .sops.yaml file";
          command = ''
            ${gen-sops-yaml} > .sops.yaml
          '';
        }
      ];
    };

    checks.sops-yaml = pkgs.runCommand "check-sops-yaml" {} ''
      cd ${./.}
      generated=$(${gen-sops-yaml})
      if ! diff -u .sops.yaml <(echo "$generated"); then
        echo "ERROR: .sops.yaml does not match generated output"
        echo "Run 'gen-sops-yaml' to update it"
        exit 1
      fi
      touch $out
    '';
  };
}
