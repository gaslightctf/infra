# infra

gaslightCTF infrastructure as code. Manages the following resources:

- `terranix/`
  - [x] GCE network, subnet, firewall
    - [x] GCE subnet, firewall
    - [ ] GCE network LB
  - [x] GCE instances
  - [ ] Cloudflare DNS records
- `colmena/`
  - [ ] NixOS config for k3s nodes
- `kubernetes/`
  - [ ] Traefik config
    - [ ] cert-manager
  - [ ] [berg](https://github.com/NoRelect/berg) deployment

## terranix

```sh
tofu-dev init
tofu-dev apply -concise
tofu-dev output -json > data/tf-output/dev.json
```
