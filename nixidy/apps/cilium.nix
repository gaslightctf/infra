{
  flake.modules.nixidy.nginx = {
    applications.nginx = {
      namespace = "nginx";
      createNamespace = true;

      resources = {
        deployments.nginx.spec = {
          replicas = 2;
          selector.matchLabels.app = "nginx";
          template = {
            metadata.labels.app = "nginx";
            spec.containers.nginx = {
              image = "nginx:1.25.1";
              ports.http.containerPort = 80;
            };
          };
        };

        services.nginx.spec = {
          selector.app = "nginx";
          ports.http.port = 80;
        };

        ingresses.nginx.spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "localhost";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "nginx";
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
