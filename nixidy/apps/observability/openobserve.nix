{
  flake.modules.nixidy.observability =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      chart = pkgs.stdenv.mkDerivation {
        name = "openobserve-helm-chart";

        src = pkgs.fetchFromGitHub {
          owner = "openobserve";
          repo = "openobserve-helm-chart";
          rev = "36a52fcc59c73021828f4ff4ef55eb3e0d087210";
          hash = "sha256-fTo05nbRDhBqvH7Ag1C1/84jwW3ZvPbUfUQBrH5cpK8=";
        };

        nativeBuildInputs = [ pkgs.kubernetes-helm ];
        buildPhase = ''
          export HOME="$TMP/.nix-helm-home"
          helm repo add minio https://charts.min.io
          helm repo update

          helm package -u "charts/openobserve-standalone"

          # probably there is a better way to do this?
          tar -xf "openobserve-standalone-0.80.3.tgz" -C $TMP
          mv "$TMP/openobserve-standalone" $out
        '';
      };
    in
    {
      applications.openobserve = {
        namespace = "openobserve";
        createNamespace = true;

        helm.releases.openobserve = {
          inherit chart;

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
              metadata.name = "data";
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
                    subPath = "db";
                    name = "data";
                  }
                  {
                    mountPath = "/data/wal";
                    subPath = "wal";
                    name = "data";
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
