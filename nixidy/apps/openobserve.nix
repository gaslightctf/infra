let
  chartAttrs = {
    repo = "https://charts.openobserve.ai";
    chart = "openobserve-standalone";
    version = "0.80.3";
    chartHash = "sha256-pzu+wBIH1FALVQgDWr2B4Wt2vL8fHfjLLzkXqJt2rxw=";
  };
in
{
  flake.modules.nixidy.openobserve =
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
                    name = "openobserve-s3";
                    key = name;
                  };
                })
                [
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
      };

      traefik.certs.openobserve = {
        secretName = "openobserve-tls";
        issuerRef = config.traefik.issuerRefs.cf;
        dnsNames = [ "openobserve.gaslightctf.cooking" ];
      };
    };
}
