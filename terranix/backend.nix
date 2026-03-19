{ lib, ... }:
{
  vars.backend_bucket = {
    sensitive = false;
  };
  terraform.backend.s3 = {
    bucket = lib.tfRef "var.backend_bucket";
    key = "terraform.tfstate";
    region = "auto";

    skip_credentials_validation = true;
    skip_region_validation = true;
    skip_requesting_account_id = true;
    skip_metadata_api_check = true;
    skip_s3_checksum = true;
  };
}
