# infra

gaslightCTF infrastructure as code. Manages the following resources:

- `terranix/`
  - [x] GCE network, subnet, firewall
    - [x] GCE subnet, firewall
    - [x] GCE network LB
  - [x] GCE instances
  - [ ] Cloudflare DNS records
- `colmena/`
  - [ ] NixOS config for k3s nodes
- `kubernetes/`
  - [ ] Traefik config
    - [ ] cert-manager
  - [ ] [berg](https://github.com/NoRelect/berg) deployment

## adding a new host

- add `instances.[name].enable = true` to ./terranix/infra/default.nix
  - `tofu-dev apply`
  - `tofu-dev output -json > data/tf-output/dev.json`
- `fetch-host-keys data/tf-output/dev.json`, update ./data/keys.nix
  - `gen-sops-yaml`
  - `sops updatekeys secrets/**/*`

## terranix

```sh
tofu-dev init
tofu-dev apply -concise
tofu-dev output -json > data/tf-output/dev.json
fetch-host-keys data/tf-output/dev.json
```
