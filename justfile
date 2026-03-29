default:
    just --list

sync env="dev": && sync-sops
    tofu-{{env}} refresh
    tofu-{{env}} output -json > $PRJ_ROOT/data/tf-output/{{env}}.json
    fetch-host-keys $PRJ_ROOT/data/tf-output/{{env}}.json | tee $PRJ_ROOT/data/keys.{{env}}.nix

sync-sops:
    nix develop -c "write-files"
    sops updatekeys secrets/**/*

ssh host *FLAGS:
    ssh -F $PRJ_ROOT/data/ssh/config {{host}} {{FLAGS}}
