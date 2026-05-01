{
  resource.google_storage_bucket.openobserve = {
    name = "gaslightctf-dev-openobserve-1";
    location = "EUROPE-NORTH1";
    public_access_prevention = "enforced";
    uniform_bucket_level_access = true;
  };
}
