let
  chartAttrs = {
    repo = "https://cloudnative-pg.github.io/charts/";
    chart = "cloudnative-pg";
    version = "0.28.0";
    chartHash = "sha256-IE5HEzMotxW00cdnmgJgDedNS42iBiuiwYRo9pe/10w=";
  };
in
{
  flake.modules.nixidy.cnpg =
    { lib, ... }:
    {
      applications.cnpg = {
        namespace = "cnpg";
        createNamespace = true;

        helm.releases.cnpg = {
          chart = lib.helm.downloadHelmChart chartAttrs;
          transformer = map (
            lib.kube.removeLabels [
              "app.kubernetes.io/version"
              "helm.sh/chart"
            ]
          );

          values = {
            config.clusterWide = true;
          };
        };
      };
    };

  perSystem =
    { inputs', ... }:
    {
      files.files = [
        {
          path_ = "nixidy/_gen/cnpg.nix";
          drv = inputs'.nixidy.packages.generators.fromChartCRD {
            name = "cnpg";
            inherit chartAttrs;
          };
        }
      ];
    };
}
