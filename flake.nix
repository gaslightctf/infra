{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";
    files.url = "github:mightyiam/files";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";

    terranix.url = "github:terranix/terranix";
    terranix.inputs.nixpkgs.follows = "nixpkgs";
    tf-providers.url = "github:nix-community/nixpkgs-terraform-providers-bin";
    tf-providers.inputs.nixpkgs.follows = "nixpkgs";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixidy.url = "github:sportshead/nixidy";
    nixidy.inputs.nixpkgs.follows = "nixpkgs";
    nixidy.inputs.nix-kube-generators.url = "github:farcaller/nix-kube-generators/810dcf792081790648ba9ae705b9a2286115ace8";
  };

  nixConfig = {
    extra-substituters = [
      "https://colmena.cachix.org"
      "https://cache.thalheim.io"
    ];
    extra-trusted-public-keys = [
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
    ];
    extra-experimental-features = [ "pipe-operators" ];
  };

  outputs =
    inputs@{ flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      imports = [
        inputs.flake-parts.flakeModules.modules

        (import-tree ./colmena)
        (import-tree ./nixos)
        (import-tree ./nixidy)

        inputs.devshell.flakeModule
        ./devshell.nix

        inputs.treefmt.flakeModule
        ./treefmt.nix

        inputs.terranix.flakeModule
        ./terranix.nix

        inputs.files.flakeModules.default
        (import-tree ./data/files)
      ];
    };
}
