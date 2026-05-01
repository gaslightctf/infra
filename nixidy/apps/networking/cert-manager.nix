let
  chartAttrs = {
    repo = "oci://quay.io/jetstack/charts";
    chart = "cert-manager";
    version = "1.20.2";
    chartHash = "sha256-4V44v91c1wUBKDr7GbhahRWCjPtl1zCT9Bd0Hn5gCYY=";
  };
in
{
  flake.modules.nixidy.cert-manager =
    { lib, ... }:
    {
      applications.cert-manager = {
        namespace = "cert-manager";
        createNamespace = true;

        helm.releases.cert-manager = {
          chart = lib.helm.downloadHelmChart chartAttrs;

          values = {
            crds.enabled = true;
          };
        };

        resources.clusterIssuers.cluster-selfsigned.spec.selfSigned = { };
      };
    };

  perSystem =
    { inputs', ... }:
    {
      files.files = [
        {
          path_ = "nixidy/_gen/cert-manager.nix";
          drv = inputs'.nixidy.packages.generators.fromChartCRD {
            name = "cert-manager";
            inherit chartAttrs;

            crds = [
              "ClusterIssuer"
              "Issuer"
              "Certificate"
            ];

            extraOpts = [
              "--set"
              "crds.enabled=true"
            ];
          };
        }
      ];
    };
}
