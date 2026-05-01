let
  chartAttrs = {
    repo = "oci://ghcr.io/open-telemetry/opentelemetry-helm-charts";
    chart = "opentelemetry-operator";
    version = "0.111.0";
    chartHash = "sha256-L6mCnylreQm8or8S9SZD6jbNIegRTM2ytSKNFAmJ4ZY=";
  };
in
{
  flake.modules.nixidy.observability =
    { lib, ... }:
    {
      applications.opentelemetry = {
        namespace = "opentelemetry";
        createNamespace = true;

        helm.releases.opentelemetry-operator = {
          chart = lib.helm.downloadHelmChart chartAttrs;

          values = {
            admissionWebhooks.certManager = {
              enabled = true;

              issuerRef = {
                kind = "ClusterIssuer";
                group = "cert-manager.io";
                name = "cluster-selfsigned";
              };
            };
          };
        };
      };
    };

  perSystem =
    { inputs', ... }:
    {
      files.files = [
        {
          path_ = "nixidy/_gen/opentelemetry-operator.nix";
          drv = inputs'.nixidy.packages.generators.fromChartCRD {
            name = "opentelemetry-operator";
            inherit chartAttrs;
          };
        }
      ];
    };
}
