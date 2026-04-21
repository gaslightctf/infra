{
  flake.modules.nixidy.dev =
    { lib, ... }:
    {
      nixidy.target.rootPath = lib.mkForce "./manifests/dev";

      applications.berg.helm.releases.berg.values = {
        gateway.domain = lib.mkForce "play-dev.gaslightctf.cooking";

        berg = {
          domain = lib.mkForce "play-dev.gaslightctf.cooking";

          # TODO: testing
          ctf.allowAnonymousAccess = lib.mkForce true;
        };
      };

      applications.traefik.resources.certificates.play-gaslightctf-cooking.spec.dnsNames = lib.mkForce [
        "play-dev.gaslightctf.cooking"
        "*.play-dev.gaslightctf.cooking"
      ];
    };
}
