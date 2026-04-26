let
  chartAttrs = {
    repo = "oci://ghcr.io/norelect/charts";
    chart = "berg";
    version = "5.15.0";
    chartHash = "sha256-gMn/HxB60OwEaLkdJSGbaoGyP3mK8UbVnbGW1TD/X0Q=";
  };
in
{
  flake.modules.nixidy.berg =
    { lib, config, ... }:
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

            frontend = {
              enabled = false;
              resources = {
                limits = {
                  cpu = "200m";
                  memory = "64Mi";
                };
                requests = {
                  cpu = "50m";
                  memory = "32Mi";
                };
              };
            };

            berg = {
              resources = {
                limits = {
                  cpu = "1000m";
                  memory = "1Gi";
                };
                requests = {
                  cpu = "250m";
                  memory = "300Mi";
                };
              };

              domain = "play.gaslightctf.cooking";
              redirectUris = [
                "http://localhost:5000/frontend/oidc-callback"
                "https://frontend-dev-21w.pages.dev/frontend/oidc-callback"
              ];

              postgresql.existingSecret.name = "berg-db-app";

              discord =
                let
                  guildId = "1463881187159441619";
                in
                {
                  existingSecret.name = "berg-discord";

                  notificationGuildId = guildId;
                  authorGuildId = guildId;
                  adminGuildId = guildId;

                  notificationChannelId = "1485397056419004568";
                  authorRoleId = "1496622317147525321";
                  adminRoleId = "1469436808604680194";
                };

              ctf = {
                eventName = "gaslightCTF 2026";
                eventOrganiser = "gaslightCTF";
                eventLogoUrl = "https://gaslightctf.cooking/assets/gaslighticoncolor.png";

                allowAnonymousAccess = true;

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

        resources.httpRoutes.berg-api.spec.rules = lib.mkForce [
          {
            matches = [
              {
                path = {
                  type = "PathPrefix";
                  value = "/api";
                };
              }
              {
                path = {
                  type = "PathPrefix";
                  value = "/swagger";
                };
              }
              {
                path = {
                  type = "Exact";
                  value = "/.well-known/openid-configuration";
                };
              }
              {
                path = {
                  type = "Exact";
                  value = "/.well-known/jwks";
                };
              }
            ];

            backendRefs = [
              {
                kind = "Service";
                name = "berg-api";
                port = 80;
              }
            ];
            filters = [
              {
                type = "ExtensionRef";
                extensionRef = {
                  group = "traefik.io";
                  kind = "Middleware";
                  name = "berg-api";
                };
              }
            ];
          }
        ];

        resources.middlewares.berg-api.spec = {
          headers = {
            accessControlAllowMethods = [
              "PUT"
              "PATCH"
              "DELETE"
            ];
            accessControlAllowHeaders = [
              "Content-Type"
              "Authorization"
            ];
            accessControlAllowOriginListRegex = [
              "http://localhost:5000"
              "https://([\\w-]+\\.)?frontend-dev-21w\\.pages\\.dev"
            ];
            addVaryHeader = true;

            customResponseHeaders = {
              "Cache-Control" = "no-store";
            };
          };
        };

        resources.clusters.berg-db.spec = {
          instances = 3;
          storage.size = "15Gi";
        };

        resources.horizontalPodAutoscalers =
          let
            mkSpec = name: {
              minReplicas = 2;
              maxReplicas = 10;

              scaleTargetRef = {
                apiVersion = "apps/v1";
                kind = "Deployment";
                inherit name;
              };

              metrics = [
                {
                  type = "Resource";
                  resource = {
                    name = "cpu";
                    target = {
                      type = "Utilization";
                      averageUtilization = 70;
                    };
                  };
                }
              ];
            };
          in
          {
            berg-api.spec = mkSpec "berg-api";
            berg-frontend = lib.mkIf config.applications.berg.helm.releases.berg.values.frontend.enabled {
              spec = mkSpec "berg-frontend";
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
