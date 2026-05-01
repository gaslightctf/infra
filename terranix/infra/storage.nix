{ lib, ... }:
{
  resource.google_storage_bucket.openobserve = {
    name = "gaslightctf-dev-openobserve-1";
    location = "EUROPE-NORTH1";
    public_access_prevention = "enforced";
    uniform_bucket_level_access = true;
  };

  resource.google_service_account.openobserve = {
    account_id = "openobserve";
  };
  resource.google_storage_bucket_iam_member.openobserve = {
    bucket = lib.tfRef "google_storage_bucket.openobserve.name";
    role = "roles/storage.objectAdmin";
    member = "serviceAccount:\${google_service_account.openobserve.email}";
  };
  resource.google_storage_hmac_key.openobserve = {
    service_account_email = lib.tfRef "google_service_account.openobserve.email";
  };
}
