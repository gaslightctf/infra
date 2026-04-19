{
  flake.modules.nixidy.http-echo = {
    applications.http-echo = {
      namespace = "http-echo";
      createNamespace = true;

      resources = {
        deployments.http-echo.spec = {
          replicas = 3;
          selector.matchLabels.app = "http-echo";
          template = {
            metadata.labels.app = "http-echo";
            spec.containers.nginx = {
              image = "mendhak/http-https-echo";
              ports.http.containerPort = 8080;
            };
          };
        };

        services.http-echo.spec = {
          selector.app = "http-echo";
          ports.http = {
            port = 80;
            targetPort = 8080;
          };
        };

        ingresses.http-echo.spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "play-dev.gaslightctf.cooking";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "http-echo";
                    port.name = "http";
                  };
                }
              ];
            }
          ];
        };
      };
    };
  };
}
