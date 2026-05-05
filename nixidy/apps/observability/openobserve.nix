let
  chartAttrs = {
    repo = "https://charts.openobserve.ai";
    chart = "openobserve-standalone";
    version = "0.80.3";
    chartHash = "sha256-pzu+wBIH1FALVQgDWr2B4Wt2vL8fHfjLLzkXqJt2rxw=";
  };
in
{
  flake.modules.nixidy.observability =
    { lib, config, ... }:
    {
      applications.openobserve = {
        namespace = "openobserve";
        createNamespace = true;

        helm.releases.openobserve = {
          chart = lib.helm.downloadHelmChart chartAttrs;

          values = {
            auth.existingRootUserSecret = {
              name = "openobserve-root-user";
            };

            extraEnv =
              map
                (name: {
                  inherit name;
                  valueFrom.secretKeyRef = {
                    name = "openobserve-env";
                    key = name;
                  };
                })
                [
                  "ZO_ROOT_USER_TOKEN"

                  "ZO_S3_ACCESS_KEY"
                  "ZO_S3_SECRET_KEY"
                  "ZO_S3_BUCKET_NAME"
                ];

            config = {
              ZO_TELEMETRY = "false";

              ZO_LOCAL_MODE_STORAGE = "s3";
              ZO_S3_PROVIDER = "s3";
              ZO_S3_SERVER_URL = "https://storage.googleapis.com";
              ZO_S3_REGION_NAME = "EUROPE-NORTH1";
              ZO_S3_FEATURE_HTTP1_ONLY = "true";
            };
          };
        };

        resources.statefulSets."openobserve-openobserve-standalone".spec = {
          volumeClaimTemplates = lib.mkForce [
            {
              metadata.name = "data-db";
              spec = {
                accessModes = [ "ReadWriteOnce" ];
                resources.requests.storage = "1Gi";
              };
            }
            {
              metadata.name = "data-wal";
              spec = {
                accessModes = [ "ReadWriteOnce" ];
                resources.requests.storage = "5Gi";
              };
            }
          ];
          template.spec = {
            volumes = lib.mkForce [
              {
                name = "data-tmp";
                emptyDir = { };
              }
            ];
            containers = [
              {
                name = "openobserve-standalone";
                volumeMounts = lib.mkForce [
                  {
                    mountPath = "/data";
                    name = "data-tmp";
                  }
                  {
                    mountPath = "/data/db";
                    name = "data-db";
                  }
                  {
                    mountPath = "/data/wal";
                    name = "data-wal";
                  }
                ];
              }
            ];
          };
        };

        resources.httpRoutes.openobserve.spec = {
          hostnames = [ "openobserve.gaslightctf.cooking" ];
          parentRefs = [
            {
              name = "traefik-gateway";
              namespace = "traefik";
              sectionName = "websecure";
            }
          ];

          rules = [
            {
              backendRefs = [
                {
                  group = "";
                  kind = "Service";
                  name = "openobserve-openobserve-standalone";
                  port = 5080;
                }
              ];
            }
          ];
        };
      };

      traefik.certs.openobserve = {
        secretName = "openobserve-tls";
        issuerRef = config.traefik.issuerRefs.cf;
        dnsNames = [ "openobserve.gaslightctf.cooking" ];
      };
    };
}
