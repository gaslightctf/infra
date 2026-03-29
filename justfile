default:
    just --list

sync env="dev": && sync-sops
    tofu-{{env}} output -json > $PRJ_ROOT/data/tf-output/{{env}}.json
    fetch-host-keys $PRJ_ROOT/data/tf-output/{{env}}.json | tee $PRJ_ROOT/data/keys.{{env}}.nix

sync-sops:
    write-files
    sops updatekeys secrets/**/*
