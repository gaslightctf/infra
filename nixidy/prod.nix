{
  # temp overrides for mini cluster
  flake.modules.nixidy.prod =
    { lib, ... }:
    {
      applications.cilium.helm.releases.cilium.values.operator.replicas = lib.mkForce 1;

      applications.berg.resources.clusters.berg-db.spec.instances = lib.mkForce 1;

      applications.berg.resources.horizontalPodAutoscalers.berg-api.spec.minReplicas = lib.mkForce 1;

      applications.berg.helm.releases.berg.values.berg.resources = lib.mkForce {
        requests = {
          cpu = "500m";
          memory = "500Mi";
        };
      };
    };
}
