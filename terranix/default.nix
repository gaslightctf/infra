{lib, ...}: {
  imports =
    builtins.map (file: ./modules/${file}) (builtins.attrNames (builtins.readDir ./modules))
    ++ [
      ./backend.nix

      ./infra
    ];

  terraform.required_providers = {
    google.source = "hashicorp/google";
  };

  vars.gcp_credentials = {ephemeral = true;};
  vars.gcp_project = {};
  provider.google = {
    credentials = lib.tfRef "var.gcp_credentials";

    project = lib.tfRef "var.gcp_project";
    region = "europe-north1";
    zone = "europe-north1-a";
  };
}
