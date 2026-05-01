let
  chartAttrs = {
    repo = "https://argoproj.github.io/argo-helm/";
    chart = "argo-cd";
    version = "9.5.4";
    chartHash = "sha256-DWqUF3BT9j9A5nbA3W1BJqI3TrwZXESVpWLU2JTVtIo=";
  };
in
{
  flake.modules.nixidy.argocd =
    { lib, config, ... }:
    {
      applications.argocd = {
        namespace = "argocd";
        createNamespace = true;

        helm.releases.argocd = {
          chart = lib.helm.downloadHelmChart chartAttrs;

          values = {
            global.domain = "argocd.gaslightctf.cooking";

            server.httproute = {
              enabled = true;
              hostnames = [ "argocd.gaslightctf.cooking" ];
              parentRefs = [
                {
                  name = "traefik-gateway";
                  namespace = "traefik";
                  sectionName = "websecure";
                }
              ];
            };

            configs.secret.argocdServerAdminPassword = "$2y$12$hP6f/kEtRpYiMB2.lkNrvOEKaEpxuGLeO56ZTzXgpT3mrAhN6bpmy";
          };
        };

        resources.certificates.argocd-server.spec = {
          issuerRef = {
            kind = "ClusterIssuer";
            group = "cert-manager.io";
            name = "cluster-selfsigned";
          };

          dnsNames = [ "argocd-server.gaslightctf.local" ];
          secretName = "argocd-server-tls";
        };

        resources.backendTLSPolicies.argocd-server.spec = {
          targetRefs = [
            {
              group = "";
              kind = "Service";
              name = "argocd-server";
              sectionName = "https";
            }
          ];

          validation = {
            caCertificateRefs = [
              {
                group = "";
                kind = "Secret";
                name = "argocd-server-tls";
              }
            ];
            hostname = "argocd-server.gaslightctf.local";
          };
        };
      };

      traefik.certs.argocd = {
        secretName = "argocd-tls";
        issuerRef = config.traefik.issuerRefs.cf;
        dnsNames = [ "argocd.gaslightctf.cooking" ];
      };
    };
}
