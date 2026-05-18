let
  chartAttrs = {
    repo = "oci://ghcr.io/bergctf/charts";
    chart = "berg";
    version = "5.15.2";
    chartHash = "sha256-aG1E/z7ozYZxsbhgB8cZ5ypXXHUviSoUxqtaIEwYLHg=";
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

            frontend.enabled = false;

            berg = {
              image = {
                repository = "ghcr.io/sportshead/berg/api";
                tag = "latest";
              };

              resources = {
                limits = {
                  cpu = "2000m";
                  memory = "1Gi";
                };
                requests = {
                  cpu = "1000m";
                  memory = "500Mi";
                };
              };
              extraEnv = [
                {
                  name = "NODE_IP";
                  valueFrom.fieldRef.fieldPath = "status.hostIP";
                }

                {
                  name = "infra__openTelemetryGrpcTracingEndpoint";
                  value = "http://$(NODE_IP):4317";
                }
                {
                  name = "infra__openTelemetryGrpcMetricsEndpoint";
                  value = "http://$(NODE_IP):4317";
                }
                {
                  name = "infra__openTelemetryGrpcLoggingEndpoint";
                  value = "http://$(NODE_IP):4317";
                }
              ];

              domain = "api.gaslightctf.cooking";
              redirectUris = [
                "https://play.gaslightctf.cooking/frontend/oidc-callback"
              ];
              postLogoutRedirectUris = [
                "https://play.gaslightctf.cooking"
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
            accessControlAllowOriginList = [
              "https://play.gaslightctf.cooking"
            ];
            addVaryHeader = true;

            customResponseHeaders = {
              "Cache-Control" = "no-store";
            };
          };
        };

        resources.deployments.berg-api.spec.replicas = lib.mkForce null;

        resources.horizontalPodAutoscalers.berg-api.spec = {
          minReplicas = 2;
          maxReplicas = 4;

          scaleTargetRef = {
            apiVersion = "apps/v1";
            kind = "Deployment";
            name = "berg-api";
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
      };

      traefik.certs.berg-api = {
        secretName = "berg-api-tls";
        issuerRef = config.traefik.issuerRefs.cf;
        dnsNames = [ "api.gaslightctf.cooking" ];
      };

      traefik.certs.berg-play = {
        secretName = "berg-play-tls";
        issuerRef = config.traefik.issuerRefs.letsencrypt;
        dnsNames = [ "*.play.gaslightctf.cooking" ];
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
