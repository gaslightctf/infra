let
  chartAttrs = {
    repo = "oci://ghcr.io/cloudflare/origin-ca-issuer-charts";
    chart = "origin-ca-issuer";
    version = "0.6.4";
    chartHash = "sha256-bUwPrx6J7aGs4pn777lnHkA/3RGjnhogbEaHnXyiTuU=";
  };

  mkCrdSrc =
    { fetchFromGitHub, ... }:
    fetchFromGitHub {
      owner = "cloudflare";
      repo = "origin-ca-issuer";
      rev = "v0.14.0";
      hash = "sha256-EgCzvKGmL04OCoOyRA2Y/fN3Pj3N+O1reYySzmPH8EE=";
    };
in
{
  flake.modules.nixidy.origin-ca-issuer =
    { pkgs, lib, ... }:
    {
      applications.origin-ca-issuer = {
        namespace = "cert-manager";

        helm.releases.origin-ca-issuer = {
          chart = lib.helm.downloadHelmChart chartAttrs;
        };

        yamls =
          let
            src = mkCrdSrc pkgs;
          in
          map builtins.readFile [
            "${src}/deploy/crds/cert-manager.k8s.cloudflare.com_clusteroriginissuers.yaml"
            "${src}/deploy/crds/cert-manager.k8s.cloudflare.com_originissuers.yaml"
          ];
      };
    };

  perSystem =
    { pkgs, inputs', ... }:
    {
      files.files = [
        {
          path_ = "nixidy/_gen/origin-ca-issuer.nix";
          drv = inputs'.nixidy.packages.generators.fromCRD {
            name = "origin-ca-issuer";

            src = mkCrdSrc pkgs;

            crds = [
              "deploy/crds/cert-manager.k8s.cloudflare.com_clusteroriginissuers.yaml"
              "deploy/crds/cert-manager.k8s.cloudflare.com_originissuers.yaml"
            ];
          };
        }
      ];
    };
}
