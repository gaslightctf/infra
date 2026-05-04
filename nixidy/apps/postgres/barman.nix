let
  chartAttrs = {
    repo = "https://cloudnative-pg.github.io/charts/";
    chart = "plugin-barman-cloud";
    version = "0.6.0";
    chartHash = "sha256-Am0F3cYWcluMKFq6PG0u1wU8jHzUi5nsZtbLFjHouw8=";
  };
in
{
  flake.modules.nixidy.cnpg =
    { lib, ... }:
    {
      applications.cnpg = {
        helm.releases.barman = {
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
          path_ = "nixidy/_gen/barman.nix";
          drv = inputs'.nixidy.packages.generators.fromChartCRD {
            name = "barman";
            inherit chartAttrs;
          };
        }
      ];
    };
}
