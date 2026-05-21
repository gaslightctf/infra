let
  mkCrdSrc =
    { fetchFromGitHub, ... }:
    fetchFromGitHub {
      owner = "kubernetes-sigs";
      repo = "gateway-api";
      rev = "v1.5.1";
      hash = "sha256-mWMvJG6esOqDBSbhExvt7L3ZTiQUOfeRBohew/m67A0=";
    };
in
{
  flake.modules.nixidy.traefik =
    { pkgs, ... }:
    {
      applications.traefik = {
        extraRawYamls =
          let
            src = mkCrdSrc pkgs;
          in
          builtins.readDir "${src}/config/crd/standard"
          |> builtins.attrNames
          |> map (
            x:
            pkgs.runCommand x { } ''
              ${pkgs.yq}/bin/yq -y '.metadata.annotations."argocd.argoproj.io/sync-options" = "ServerSideApply=true"' \
                "${src}/config/crd/standard/${x}" > $out
            ''
          );
      };
    };

  perSystem =
    { pkgs, inputs', ... }:
    {
      files.files = [
        {
          path_ = "nixidy/_gen/gateway-api.nix";
          drv =
            let
              src = mkCrdSrc pkgs;
            in
            inputs'.nixidy.packages.generators.fromCRD {
              name = "gateway-api";

              inherit src;

              crds =
                builtins.readDir "${src}/config/crd/standard"
                |> builtins.attrNames
                |> map (x: "config/crd/standard/${x}");
            };
        }
      ];
    };
}
