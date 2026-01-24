{lib, ...}: let
  sensitiveVar = {
    type = "string";
    sensitive = true;
  };
in {
  terraform.backend.s3 = {
    bucket = "tf-state";
    key = "terraform.tfstate";
    region = "auto";
    workspace_key_prefix = "workspaces";

    # endpoints.s3 = ''https://''${data.sops_file.backend.data["account_id"]}.r2.cloudflarestorage.com'';
    #
    # access_key = lib.tfRef ''data.sops_file.backend.data["access_key"]'';
    # secret_key = lib.tfRef ''data.sops_file.backend.data["secret_key"]'';

    skip_credentials_validation = true;
    skip_region_validation = true;
    skip_requesting_account_id = true;
    skip_metadata_api_check = true;
    skip_s3_checksum = true;
  };

  # data.sops_file.backend.source_file = "secrets/tf/backend.yaml";
}
