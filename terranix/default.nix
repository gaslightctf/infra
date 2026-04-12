{ lib, providers, ... }:
let
  mkRequiredProvider = p: {
    source =
      lib.replaceString "registry.terraform.io" "registry.opentofu.org"
        p.provider-source-address;
    version = p.version;
  };
in
{
  terraform.required_providers = {
    google = mkRequiredProvider providers.hashicorp.google;
    cloudflare = mkRequiredProvider providers.cloudflare.cloudflare;
  };

  vars.gcp_credentials = {
    ephemeral = true;
  };
  vars.gcp_project = { };
  provider.google = {
    credentials = lib.tfRef "var.gcp_credentials";

    project = lib.tfRef "var.gcp_project";
    region = "europe-north1";
    zone = "europe-north1-a";
  };

  vars.cf_api_token = {
    ephemeral = true;
  };
  provider.cloudflare = {
    api_token = lib.tfRef "var.cf_api_token";
  };
}
