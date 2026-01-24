{
  perSystem = {pkgs, ...}: let
    tofu = pkgs.opentofu.withPlugins (p: with p; [hashicorp_google carlpett_sops]);
    wrappedTofu = pkgs.writeShellScriptBin "tofu" ''
      ${pkgs.sops}/bin/sops exec-env ${./secrets/tf/backend.yaml} "${tofu}/bin/tofu $@"
    '';
  in {
    terranix = {
      exportDevShells = false;

      terranixConfigurations.default = {
        terraformWrapper.package = wrappedTofu;
        modules = [./terranix];
      };
    };
  };
}
