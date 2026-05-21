let
  mkChartAttrs = pkgs: {
    repo = "https://traefik.github.io/charts/";
    chart = "traefik";
    version = "40.2.0";
    chartHash = "sha256-KSiEnX4nLX4+3b1KSK88c7PYeEURmoSnY3+U3h4HdzA=";
  };
in
{
  flake.modules.nixidy.traefik =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options.traefik = {
        issuerRefs = {
          letsencrypt = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {
              name = "letsencrypt";
            };
          };
          cf = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {
              group = "cert-manager.k8s.cloudflare.com";
              kind = "OriginIssuer";
              name = "cf-issuer";
            };
          };
        };

        certs = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
        };
      };

      config.applications.traefik = {
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
              alpnProtocols = [
                "h2"
                "http/1.1"
                "acme-tls/1"
              ];
            };

            ingressClass = {
              enabled = true;
              isDefaultClass = true;
            };

            providers.kubernetesGateway = {
              enabled = true;
            };
            gateway = {
              enabled = true;
              name = "traefik-gateway";

              listeners =
                let
                  namespacePolicy = {
                    from = "All";
                  };

                  certificateRefs =
                    map (c: {
                      kind = "Secret";
                      name = c.secretName;
                    })
                    <| builtins.attrValues config.traefik.certs;
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

        resources.gateways.traefik-gateway.spec = {
          tls.frontend.perPort = [
            {
              port = 443;
              tls.validation.caCertificateRefs = [
                {
                  group = "";
                  kind = "ConfigMap";
                  name = "cf-global-aop-ca-cert";
                }
              ];
            }
          ];
        };

        resources.certificates = builtins.mapAttrs (n: v: { spec = v; }) config.traefik.certs;

        resources.configMaps.cf-global-aop-ca-cert.data."ca.crt" =
          builtins.readFile
          <| pkgs.fetchurl {
            url = "https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem";
            hash = "sha256-wU/tDOUhDbBxn+oR0fELM3UNwX1gmur0fHXp7/DXuEM";
          };

        resources.issuers.letsencrypt.spec = {
          acme = {
            email = "acme@gaslightctf.cooking";
            profile = "tlsserver";
            server = "https://acme-v02.api.letsencrypt.org/directory";
            privateKeySecretRef.name = "acme-account-letsencrypt";

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

        resources.originIssuers.cf-issuer.spec = {
          requestType = "OriginECC";
          auth.tokenRef = {
            name = "cf-api-token";
            key = "cf-api-token";
          };
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
