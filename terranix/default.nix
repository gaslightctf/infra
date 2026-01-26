{
  imports = [
    ./vars.nix
    ./backend.nix

    ./infra
  ];

  terraform.required_providers = {
    google.source = "hashicorp/google";
  };
}
