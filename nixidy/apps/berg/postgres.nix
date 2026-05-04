{
  flake.modules.nixidy.berg = {
    applications.berg = {
      resources.objectStores.r2.spec.configuration = {
        wal.compression = "zstd";

        destinationPath = "s3://barman";
        endpointURL = "https://7a7328f4f35d8ae675edeeb50d34c40e.r2.cloudflarestorage.com";

        s3Credentials = {
          accessKeyId = {
            name = "barman-r2";
            key = "accessKeyId";
          };

          secretAccessKey = {
            name = "barman-r2";
            key = "secretAccessKey";
          };
        };
      };

      resources.clusters.berg-db.spec =
        let
          plugin = {
            name = "barman-cloud.cloudnative-pg.io";
            isWALArchiver = true;
            parameters.barmanObjectName = "r2";
          };
        in
        {
          instances = 3;
          storage.size = "15Gi";

          plugins = [ plugin ];
          externalClusters = [
            {
              name = "source";
              inherit plugin;
            }
          ];

          bootstrap.recovery.source = "source";
        };

      resources.backups.berg-db-base.spec = {
        cluster.name = "berg-db";
        method = "plugin";
        pluginConfiguration.name = "barman-cloud.cloudnative-pg.io";
      };
    };
  };
}
