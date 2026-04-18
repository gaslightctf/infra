# infra

gaslightCTF infrastructure as code. Extremely overengineered (<3 Nix)

Manages the following resources:

- `terranix/`
  - [x] GCE network, subnet, firewall
    - [x] GCE subnet, firewall
    - [x] GCE network LB
  - [x] GCE instances
  - [ ] Cloudflare DNS records
    - [ ] `play[-dev].` -> network-lb
    - [ ] `chall[-dev].` -> network-lb
- `colmena/`
  - [x] NixOS config for k3s nodes
  - [ ] monitoring
    - [ ] logs go somewhere
    - [ ] metrics go somewhere
- `kubernetes/`
  - [ ] storage
    - [ ] CSI GCE PD driver
  - [ ] Traefik config
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

## cilium
not declarative :(

using `services.k3s.autoDeployCharts` creates a chicken-and-egg: k3s won't start the `helm-install-cilium` pod because there's no CNI

also trying to install cilium with agent nodes already connected makes the 
operator go on the agent nodes for some idiotic reason, which means it can't connect to 
the api server (since cilium isn't up yet), which means cilium doesn't come up... what (skill issue probably, something something taints would probably fix this)

```sh
cilium install --version 1.19.3 --set=ipam.operator.clusterPoolIPv4PodCIDRList="10.42.0.0/16"
```
