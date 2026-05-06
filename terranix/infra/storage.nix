{ lib, ... }:
let
  mkStorageModule = n: {
    resource.google_storage_bucket.${n} = {
      name = lib.tfRef ''replace("${n}''${var.dns_record_suffix}", ".", "-")'';
      location = "EUROPE-NORTH1";
      public_access_prevention = "enforced";
      uniform_bucket_level_access = true;
    };

    resource.google_service_account.${n} = {
      # pad to min 6 chars
      account_id = "${n}-bucket";
    };
    resource.google_storage_bucket_iam_member.${n} = {
      bucket = lib.tfRef "google_storage_bucket.${n}.name";
      role = "roles/storage.objectAdmin";
      member = "serviceAccount:\${google_service_account.${n}.email}";
    };
    resource.google_storage_hmac_key.${n} = {
      service_account_email = lib.tfRef "google_service_account.${n}.email";
    };
  };
in
{
  imports = [
    (mkStorageModule "openobserve")
    (mkStorageModule "k8up")
  ];
}
