{
  flake.nixosModules.k3s-server = {
    services.k3s = {
      role = "server";

      nodeTaint = [
        "node-role.kubernetes.io/control-plane:PreferNoSchedule"
      ];

      extraFlags = [
        "--kubelet-arg=eviction-hard=memory.available<200Mi"
        "--kubelet-arg=system-reserved=memory=1.5Gi"
      ];
    };
  };
}
