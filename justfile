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

# TODO: use helm for this
install-cilium env="dev" op="install": (fetch-kubeconfig env)
    @echo "Make sure that ssh forwarding is up!"
    @echo "  screen -dm just forward-kubectl {{env}}"

    # hardcoded eevee ip for k8sServiceHost
    cilium {{op}} --version 1.19.3 \
        --set kubeProxyReplacement=true \
        --set k8sServiceHost=10.6.7.10 \
        --set ipam.operator.clusterPoolIPv4PodCIDRList="10.67.0.0/16" \
        --set ipv4NativeRoutingCIDR="10.0.0.0/8" \
        --set gke.enabled=true \
        --set ipam.mode=kubernetes \
        --set routingMode=native \
        --set autoDirectNodeRoutes=false \
        --set endpointRoutes.enabled=true \
        --set operator.replicas=2 \
        --set nodeIPAM.enabled=true \

    cilium status --wait

# must pass env explicitly
provision env host:
    #!/usr/bin/env bash
    set -euxo pipefail

    # use yq as it is in the devshell
    host_ip=$(yq -r '.{{host}}_ip_public.value' $PRJ_ROOT/data/tf-output/{{env}}.json)
    nixos-anywhere --copy-host-keys \
        --flake .#{{env}}-{{host}} \
        --target-host nixos-anywhere@$host_ip \
