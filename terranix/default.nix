{ lib, ... }:
{
  imports =
    builtins.map (file: ./modules/${file}) (builtins.attrNames (builtins.readDir ./modules))
    ++ [
      ./backend.nix

      ./infra
    ];

  terraform.required_providers = {
    google.source = "hashicorp/google";
    cloudflare.source = "cloudflare/cloudflare";
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
