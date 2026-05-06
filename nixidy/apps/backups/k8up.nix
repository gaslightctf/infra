let
  chartAttrs = {
    repo = "https://k8up-io.github.io/k8up";
    chart = "k8up";
    version = "4.9.0";
    chartHash = "sha256-5w+1IBxs4i7TOJpXYexs1pDhCAkrYW9Z9Ss5di9DIKU=";
  };
in
{
  flake.modules.nixidy.k8up =
    { lib, ... }:
    {
      applications.k8up = {
        namespace = "k8up";
        createNamespace = true;

        helm.releases.k8up = {
          chart = lib.helm.downloadHelmChart chartAttrs;

          values = { };
        };
      };
    };

  perSystem =
    { inputs', ... }:
    {
      files.files = [
        {
          path_ = "nixidy/_gen/k8up.nix";
          drv = inputs'.nixidy.packages.generators.fromChartCRD {
            name = "k8up";
            inherit chartAttrs;

            namePrefix = "k8up";
          };
        }
      ];
    };
}
