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

      resources.clusters.berg-db = {
        metadata.annotations = {
          "cnpg.io/skipEmptyWalArchiveCheck" = "enabled";
        };
        spec =
          let
            plugin = {
              name = "barman-cloud.cloudnative-pg.io";
              isWALArchiver = true;
              parameters = {
                barmanObjectName = "r2";
                serverName = "berg-db";
              };
            };
          in
          {
            instances = 3;
            storage.size = "15Gi";

            plugins = [ plugin ];
            # externalClusters = [
            #   {
            #     name = "source";
            #     inherit plugin;
            #   }
            # ];

            bootstrap.initdb = { };
            # bootstrap.recovery.source = "source";
          };
      };

      resources.backups.berg-db-base.spec = {
        cluster.name = "berg-db";
        method = "plugin";
        pluginConfiguration.name = "barman-cloud.cloudnative-pg.io";
      };

      resources.scheduledBackups.berg-db.spec = {
        cluster.name = "berg-db";
        backupOwnerReference = "self";
        schedule = "0 0 * * *";

        immediate = true;

        method = "plugin";
        pluginConfiguration.name = "barman-cloud.cloudnative-pg.io";
      };
    };
  };
}
