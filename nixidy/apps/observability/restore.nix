{
  flake.modules.nixidy.restore =
    { config, ... }:
    {
      applications.openobserve = {
        resources.persistentVolumeClaims.data-openobserve-openobserve-standalone-0.spec = {
          accessModes = [ "ReadWriteOnce" ];
          resources.requests.storage = "5Gi";
        };

        resources.k8upRestores.openobserve.spec = {
          restoreMethod.folder.claimName = "data-openobserve-openobserve-standalone-0";

          inherit (config.applications.openobserve.resources.k8upSchedules.backup.spec) backend;
        };
      };
    };
}
