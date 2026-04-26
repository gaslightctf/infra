let
  gatewayCRDs =
    pkgs:
    pkgs.fetchurl {
      url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/experimental-install.yaml";
      hash = "sha256-98x9MJp62dMWk4NBBG7YHEDnh9gILwsoHfOSYomnpEU=";
    };

  mkChartAttrs = pkgs: {
    repo = "https://traefik.github.io/charts/";
    chart = "traefik";
    version = "40.0.0-rc.2";
    chartHash = "sha256-F6YpdM0SXZy6ovQQH3AZKSFVNL7zoEPkULcAw+SfXFo=";

    extraFlags =
      # bash
      ''
        # THIS LINE allows command injection in extraFlags, hella hacky
        cp ${gatewayCRDs pkgs} $OUT_DIR/traefik/crds/gateway-standard-install.yaml
      '';
  };
in
{
  flake.modules.nixidy.traefik =
    { pkgs, lib, ... }:
    {
      applications.traefik = {
        namespace = "traefik";
        createNamespace = true;

        helm.releases.traefik = {
          chart = lib.helm.downloadHelmChart (mkChartAttrs pkgs);

          values = {
            # networking to :80 and :443 handled by Cilium Portmap
            # https://docs.cilium.io/en/latest/installation/cni-chaining-portmap/
            service.enabled = false;
            deployment = {
              kind = "DaemonSet";

              healthchecksPort = 443;
              healthchecksScheme = "HTTPS";
            };

            updateStrategy.rollingUpdate.maxUnavailable = 1;
            updateStrategy.rollingUpdate.maxSurge = 0;

            additionalArguments = [
              "--ping.entrypoint=websecure"
            ];

            logs = {
              # general.level = "DEBUG";
              access.enabled = true;
            };

            tlsOptions.default = {
              sniStrict = false;
              alpnProtocols = [ "http/1.1" ];
            };

            ingressClass = {
              enabled = true;
              isDefaultClass = true;
            };

            providers.kubernetesGateway = {
              enabled = true;
              experimentalChannel = true;
            };
            gateway = {
              enabled = true;
              name = "traefik-gateway";

              listeners =
                let
                  namespacePolicy = {
                    from = "All";
                  };

                  certificateRefs = [
                    {
                      kind = "Secret";
                      name = "traefik-main-tls";
                    }
                  ];
                  mode = "Terminate";
                in
                {
                  web = {
                    inherit namespacePolicy;

                    port = 80;
                    protocol = "HTTP";
                  };
                  http-chall = {
                    inherit namespacePolicy;

                    port = 1337;
                    protocol = "HTTP";
                  };

                  websecure = {
                    inherit namespacePolicy certificateRefs mode;

                    port = 443;
                    protocol = "HTTPS";
                  };
                  https-chall = {
                    inherit namespacePolicy certificateRefs mode;

                    port = 1337;
                    protocol = "HTTPS";
                  };
                  tls-chall = {
                    inherit namespacePolicy certificateRefs mode;

                    port = 31337;
                    protocol = "TLS";
                  };
                };
            };

            ports = {
              web = {
                port = 80;
              };

              websecure = {
                port = 443;
                hostPort = 443;
              };

              http-chall = {
                port = 1337;
                hostPort = 1337;
              };

              tls-chall = {
                port = 31337;
                hostPort = 31337;
              };
            };
          };
        };

        resources.issuers.letsencrypt-staging.spec = {
          acme = {
            email = "acme@gaslightctf.cooking";
            profile = "tlsserver";
            server = "https://acme-staging-v02.api.letsencrypt.org/directory";
            privateKeySecretRef.name = "acme-account-letsencrypt-staging";

            solvers = [
              {
                dns01.cloudflare.apiTokenSecretRef = {
                  name = "cf-api-token";
                  key = "cf-api-token";
                };

                selector.dnsZones = [
                  "gaslightctf.cooking"
                ];
              }
            ];
          };
        };

        resources.certificates.traefik-main.spec = {
          secretName = "traefik-main-tls";
          issuerRef.name = "letsencrypt-staging";
          dnsNames = [
            "argocd.gaslightctf.cooking"

            "play.gaslightctf.cooking"
            "*.play.gaslightctf.cooking"
          ];
        };
      };
    };

  perSystem =
    { inputs', pkgs, ... }:
    {
      files.files = [
        {
          path_ = "nixidy/_gen/traefik.nix";
          drv = inputs'.nixidy.packages.generators.fromChartCRD {
            name = "traefik";
            chartAttrs = mkChartAttrs pkgs;
          };
        }
      ];
    };
}
