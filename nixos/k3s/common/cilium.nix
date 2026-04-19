{
  flake.nixosModules.k3s-common =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.cilium-cli ];
      services.k3s = {
        nodeTaint = [
          "node.cilium.io/agent-not-ready:NoExecute"
        ];
      };
    };
}
