{ self, ... }:
let
  ips = import "${self}/data/ips.nix";
in
{
  flake.modules.nixidy.cilium =
    { lib, ... }:
    {
      applications.cilium = {
        namespace = "kube-system";

        helm.releases.cilium = {
          chart = lib.helm.downloadHelmChart {
            repo = "oci://quay.io/cilium/charts";
            chart = "cilium";
            version = "1.19.3";
            chartHash = "sha256-rt3TlLpIMTLyN+DZFRpHItt7tadQ3k+BghkfwhI8Yaw=";
          };

          values = {
            kubeProxyReplacement = true;
            k8sServiceHost = ips.instances.eevee.local;
            k8sServicePort = 6443;

            ipam = {
              mode = "kubernetes";
              operator.clusterPoolIPv4PodCIDRList = ips.podCIDR;
            };

            ipv4NativeRoutingCIDR = "10.0.0.0/8";
            routingMode = "native";
            autoDirectNodeRoutes = false;
            endpointRoutes.enabled = true;

            gke.enabled = true;
            nodeIPAM.enabled = true;

            operator.replicas = 2;
          };
        };
      };
    };
}
