let
  chartAttrs = {
    repo = "https://traefik.github.io/charts/";
    chart = "traefik";
    version = "39.0.8";
    chartHash = "sha256-pXQOVC70PKdNyqbRPaw31mjSsYhlPT7GsCDI64I1oys=";
  };
in
{
  flake.modules.nixidy.traefik =
    { lib, ... }:
    {
      applications.traefik = {
        namespace = "traefik";
        createNamespace = true;

        helm.releases.traefik = {
          chart = lib.helm.downloadHelmChart chartAttrs;

          values = {
            ingressClass = {
              enabled = true;
              isDefaultClass = true;
            };

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

            ports = {
              web = {
                port = 80;
              };

              websecure = {
                port = 443;
                hostPort = 443;
              };

              chall-https = {
                port = 1337;
                hostPort = 1337;
                http.tls.enabled = true;
              };
            };

            additionalArguments = [
              "--ping.entrypoint=websecure"
            ];

            logs = {
              # general.level = "DEBUG";
              access.enabled = true;
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
      };
    };

  perSystem =
    { inputs', ... }:
    {
      files.files = [
        {
          path_ = "nixidy/_gen/traefik.nix";
          drv = inputs'.nixidy.packages.generators.fromChartCRD {
            name = "traefik";
            inherit chartAttrs;
          };
        }
      ];
    };
}
