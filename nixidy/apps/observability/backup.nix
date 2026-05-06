{
  flake.modules.nixidy.k8up = {
    applications.openobserve = {
      resources.k8upSchedules.backup.spec = {
        backend = {
          repoPasswordSecretRef = {
            name = "restic-password";
            key = "password";
          };

          s3 = {
            endpoint = "https://storage.googleapis.com";
            bucket = "k8up-gaslightctf-cooking";

            accessKeyIDSecretRef = {
              name = "k8up-gcs";
              key = "accessKeyID";
            };
            secretAccessKeySecretRef = {
              name = "k8up-gcs";
              key = "secretAccessKey";
            };
          };
        };

        backup = {
          schedule = "*/30 * * * *";
          failedJobsHistoryLimit = 2;
          successfulJobsHistoryLimit = 2;
        };
        prune = {
          schedule = "55 * * * *";
          failedJobsHistoryLimit = 2;
          successfulJobsHistoryLimit = 2;

          retention = {
            keepLast = 5;
            keepDaily = 7;
          };
        };
      };
    };
  };
}
