let
  chartAttrs = {
    repo = "oci://ghcr.io/norelect/charts";
    chart = "berg";
    version = "5.13.4";
    chartHash = "sha256-AVqOKz1QcNRLL2DYhQ6HURIbk3Iqu5tsvVMm8MjUegs=";
  };
in
{
  flake.modules.nixidy.berg =
    { lib, ... }:
    {
      applications.berg = {
        namespace = "berg";
        createNamespace = true;

        helm.releases.berg = {
          chart = lib.helm.downloadHelmChart chartAttrs;

          values = {
            gateway = {
              domain = "play.gaslightctf.cooking";
              name = "traefik-gateway";
              namespace = "traefik";

              httpListenerName = "web";
              httpsListenerName = "websecure";
            };

            berg = {
              domain = "play.gaslightctf.cooking";

              ctf = {
                eventName = "gaslightCTF 2026";
                eventOrganiser = "gaslighting";
                eventLogoUrl = "https://gaslightctf.cooking/assets/gaslightCTFlogo.gif";

                allowAnonymousAccess = false;

                start = "2026-08-14T12:00:00Z";
                end = "2026-08-17T12:00:00Z";

                teams = true;

                playerAttributes = [
                  {
                    name = "division";
                    title = "Division";
                    description = "Select your prize division. Please reach out with any questions regarding eligibility!";
                    public = true;
                    required = true;
                    values = [
                      {
                        value = "secondary";
                        title = "Secondary School";
                        description = "Pre-university students, e.g. secondary school, high school";
                      }
                      {
                        value = "uni";
                        title = "University";
                        description = "Higher education students, e.g. university, college";
                      }
                      {
                        value = "open";
                        title = "Open";
                        description = "Anybody!";
                      }
                    ];
                  }
                ];
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
          path_ = "nixidy/_gen/berg.nix";
          drv = inputs'.nixidy.packages.generators.fromChartCRD {
            name = "berg";
            inherit chartAttrs;
          };
        }
      ];
    };
}
