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
            k8s.apiServerURLs =
              let
                servers = [
                  ips.instances.rayquaza.local
                  ips.instances.kyogre.local
                  ips.instances.groudon.local
                ];
              in
              builtins.concatStringsSep " " <| map (ip: "https://${ip}:6443") servers;

            ipam = {
              mode = "kubernetes";
              operator.clusterPoolIPv4PodCIDRList = ips.podCIDR;
            };

            ipv4NativeRoutingCIDR = "10.0.0.0/8";
            routingMode = "native";
            autoDirectNodeRoutes = false;
            endpointRoutes.enabled = true;
            bpf.masquerade = true;

            nodeIPAM.enabled = true;

            operator.replicas = 2;

            hubble = {
              relay.enabled = true;
              ui.enabled = true;

              tls.auto = {
                method = "certmanager";

                certManagerIssuerRef = {
                  kind = "Issuer";
                  group = "cert-manager.io";
                  name = "cilium-issuer";
                };
              };
            };
          };
        };

        resources.certificates.cilium-ca.spec = {
          isCA = true;
          commonName = "cilium-ca";
          secretName = "cilium-ca";
          privateKey = {
            algorithm = "ECDSA";
            size = 256;
          };
          issuerRef = {
            kind = "ClusterIssuer";
            group = "cert-manager.io";
            name = "cluster-selfsigned";
          };
        };
        resources.issuers.cilium-issuer.spec = {
          ca.secretName = "cilium-ca";
        };
      };
    };
}
