# infra

![hackatime badge](https://hackatime.hackclub.com/api/v1/badge/U07EFCL1GDN/gaslightctf/infra)

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
- `nixidy/`
  - [ ] storage
    - [ ] CSI GCE PD driver
  - [x] cilium config
  - [x] Traefik config
    - [x] cert-manager
  - [x] [berg](https://github.com/NoRelect/berg) deployment
  - [ ] argocd config

## adding a new host

- add `instances.[name].enable = true` to ./terranix/infra/default.nix
  - `tofu-dev apply`
- `just sync dev`, update ./data/keys.nix

## terranix

```sh
tofu-dev init
tofu-dev apply -concise

# update ./secrets/dev/k8s/observability.yaml
tofu-dev state show -show-sensitive google_storage_hmac_key.openobserve
# update ./secrets/dev/k8s/k8up.yaml
tofu-dev state show -show-sensitive google_storage_hmac_key.k8up
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
nixidy bootstrap .#dev | kubectl apply -f-
```
