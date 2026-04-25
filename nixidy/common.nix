{ self, ... }:
{
  flake.modules.nixidy.common =
    { lib, ... }:
    {
      imports = [
        self.modules.nixidy.cilium
        self.modules.nixidy.traefik
        self.modules.nixidy.cert-manager

        self.modules.nixidy.cnpg
        self.modules.nixidy.berg
      ];

      nixidy.target = {
        repository = "https://github.com/gaslightctf/infra.git";
        branch = "master";

        # overriden in dev.nix
        rootPath = "./manifests/prod";
      };

      nixidy.defaults.helm.transformer = map (
        lib.kube.removeLabels [
          "app.kubernetes.io/managed-by"
          "app.kubernetes.io/version"
          "helm.sh/chart"
        ]
      );
    };
}
