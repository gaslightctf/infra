default:
    just --list

sync env="dev": && sync-sops
    tofu-{{env}} output -json > $PRJ_ROOT/data/tf-output/{{env}}.json
    fetch-host-keys $PRJ_ROOT/data/tf-output/{{env}}.json | tee $PRJ_ROOT/data/keys.{{env}}.nix

sync-sops:
    nix develop -c "write-files"
    sops updatekeys secrets/**/*

ssh host *FLAGS:
    ssh -F $PRJ_ROOT/data/ssh/config {{host}} {{FLAGS}}

forward-kubectl env="dev": && (ssh (env + "-eevee") "-ND" "41337")
    @echo "Forwarding to {{env}}"

fetch-kubeconfig env="dev":
    just ssh {{env}}-eevee -- "cat /etc/rancher/k3s/k3s.yaml" \
        | yq -y '.clusters[0].cluster."proxy-url" = "socks5://localhost:41337"' \
        > .kubeconfig

inspect-tree dir:
    eza -Tla --git --follow-symlinks {{dir}}

build-nixidy env="dev": && (inspect-tree "result")
    nixidy build .#{{env}}

switch-nixidy env="dev": && (inspect-tree "manifests/dev")
    nixidy switch .#{{env}}

# must pass env explicitly
provision env host:
    #!/usr/bin/env bash
    set -euxo pipefail

    # use yq as it is in the devshell
    host_ip=$(yq -r '.{{host}}_ip_public.value' $PRJ_ROOT/data/tf-output/{{env}}.json)
    nixos-anywhere --copy-host-keys \
        --flake .#{{env}}-{{host}} \
        --target-host nixos-anywhere@$host_ip \
