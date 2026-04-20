# infra

gaslightCTF infrastructure as code. Extremely overengineered (<3 Nix)

Manages the following resources:

- `terranix/`
  - [x] GCE network, subnet, firewall
    - [x] GCE subnet, firewall
    - [x] GCE network LB
  - [x] GCE instances
  - [x] Cloudflare DNS records
    - [x] `play[-dev].` -> network-lb
    - [x] `chall[-dev].` -> network-lb
- `colmena/`
  - [x] NixOS config for k3s nodes
  - [ ] monitoring
    - [ ] logs go somewhere
    - [ ] metrics go somewhere
- `nixidy`
  - [ ] storage
    - [ ] CSI GCE PD driver
  - [x] cilium config
  - [x] Traefik config
    - [ ] cert-manager
  - [ ] [berg](https://github.com/NoRelect/berg) deployment

## adding a new host

- add `instances.[name].enable = true` to ./terranix/infra/default.nix
  - `tofu-dev apply`
- `just sync dev`, update ./data/keys.nix

## terranix

```sh
tofu-dev init
tofu-dev apply -concise
just sync
# apply with new ssh keys
colmena apply --on @dev
```

## nixidy

```sh
just build-nixidy dev
just switch-nixidy dev
```

## kubectl access

```sh
just fetch-kubeconfig
screen -dm just forward-kubectl
```

## bootstrapping cluster

```sh
tofu-dev apply
just sync

just provision dev eevee
just provision dev vaporeon
...

just fetch-kubeconfig
screen -dm just forward-kubectl

patch-pod-cidrs
nixidy apply .#dev
```
