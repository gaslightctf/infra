{
  flake.nixosModules.k3s-server = {
    services.k3s = {
      role = "server";

      # autoDeployCharts.cilium = {
      #   name = "cilium";
      #   repo = "oci://quay.io/cilium/charts/cilium";
      #   version = "1.19.3";
      #   hash = "sha256-yOBd+eq/kBnmL1ED4fNYFLTxtDkW+IUZ5a5ONsaapCs=";
      #
      #   targetNamespace = "kube-system";
      # };
    };
  };
}
