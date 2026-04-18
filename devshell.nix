{
  perSystem =
    {
      pkgs,
      inputs',
      config,
      ...
    }:
    {
      devshells.default = rec {
        name = "gaslightCTF infra";
        motd = ''
          {202}🔥 Welcome to ${name}{reset}
          $(type -p countdown &>/dev/null && countdown)
          $(type -p menu &>/dev/null && menu)
        '';

        packages = [
          pkgs.eza
        ];

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
            package = pkgs.ssh-to-age;
            category = "secrets";
          }

          {
            package = pkgs.google-cloud-sdk;
            category = "deploy";
            name = "gcloud";
          }
          {
            package = inputs'.colmena.packages.colmena;
            category = "deploy";
          }
          {
            package = pkgs.nixos-anywhere;
            category = "deploy";
          }

          {
            package = inputs'.nixidy.packages.default;
            category = "k8s";
            help = "Kubernetes GitOps with nix and Argo CD";
          }
          {
            package = pkgs.kubectl;
            category = "k8s";
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
            package = pkgs.just;
            category = "util";
          }
          {
            package = config.files.writer.drv;
            help = "Write generated files (see data/files)";
            category = "util";
          }
          {
            package = pkgs.yq;
            category = "util";
          }

          {
            name = "countdown";
            help = "Display countdown to gaslightCTF 2026";
            command =
              # bash
              ''
                START_DATE="2026-08-14T12:00:00Z"
                END_DATE="2026-08-17T12:00:00Z"

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
            name = "fetch-host-keys";
            help = "Fetch the ssh and age keys of the VMs from the supplied tf-output";
            command =
              # bash
              ''
                set -euo pipefail

                JSON_FILE="''${1:?Usage: $0 <path-to-tf-output.json>}"

                instances=$(${pkgs.jq}/bin/jq -r 'to_entries[] | select(.key | endswith("_ip_public")) | .key | gsub("_ip_public$"; "")' "$JSON_FILE")

                echo "{"
                for instance in $instances; do
                    echo "  $instance = {"

                    public_ip=$(${pkgs.jq}/bin/jq -r ".''${instance}_ip_public.value" "$JSON_FILE")
                    keyscan=$(${pkgs.openssh}/bin/ssh-keyscan -qt ed25519 "$public_ip" 2>/dev/null)

                    age_key=$(${pkgs.ssh-to-age}/bin/ssh-to-age <<< "$keyscan")
                    echo "    age = \"$age_key\";"

                    ssh_key=$(cut -d' ' -f2- <<< "$keyscan")
                    echo "    ssh = \"$ssh_key\";"

                    echo "  };"
                done
                echo "}"
              '';
          }
        ];
      };
    };
}
