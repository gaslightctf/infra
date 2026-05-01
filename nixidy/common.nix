{ self, ... }:
{
  flake.modules.nixidy.common =
    { lib, ... }:
    {
      imports = [
        self.modules.nixidy.argocd

        self.modules.nixidy.cilium
        self.modules.nixidy.traefik
        self.modules.nixidy.cert-manager

        self.modules.nixidy.openobserve

        self.modules.nixidy.cnpg
        self.modules.nixidy.berg

        self.modules.nixidy.challs-2026
      ];

      nixidy = {
        target = {
          repository = "https://github.com/gaslightctf/infra.git";
          branch = "master";

          # overriden in dev.nix
          rootPath = "./manifests/prod";
        };

        defaults = {
          syncPolicy = {
            autoSync = {
              enable = true;
              prune = true;
              selfHeal = true;
            };
          };

          helm.transformer = map (
            (lib.flip lib.pipe) [
              (lib.kube.removeLabels [
                "app.kubernetes.io/managed-by"
                "app.kubernetes.io/version"
                "helm.sh/chart"
              ])
              (
                m:
                lib.recursiveUpdate m
                <| lib.optionalAttrs (m.kind == "CustomResourceDefinition") {
                  metadata.annotations."argocd.argoproj.io/sync-options" = "ServerSideApply=true";
                }
              )
            ]
          );
        };
      };
    };
}
