{
  flake.modules.nixidy.dev =
    { lib, ... }:
    {
      nixidy.target.rootPath = lib.mkForce "./manifests/dev";

      applications.berg.helm.releases.berg.values = {
        gateway.domain = lib.mkForce "play-dev.gaslightctf.cooking";

        berg = {
          domain = lib.mkForce "play-dev.gaslightctf.cooking";

          ctf.start = lib.mkForce "2026-04-25T22:22:30Z";

          discord =
            let
              guildId = lib.mkForce "1217071243237265458";
            in
            {
              notificationGuildId = guildId;
              playerGuildId = guildId;
              authorGuildId = guildId;
              adminGuildId = guildId;

              notificationChannelId = lib.mkForce "1443695109878059140";
              playerRoleId = lib.mkForce "1496621507994980363";
              authorRoleId = lib.mkForce "1496621554090643456";
              adminRoleId = lib.mkForce "1496621555281825913";
            };
        };
      };

      applications.traefik.resources.certificates.traefik-main.spec.dnsNames = lib.mkForce [
        "argocd-dev.gaslightctf.cooking"

        "play-dev.gaslightctf.cooking"
        "*.play-dev.gaslightctf.cooking"
      ];

      applications.argocd.helm.releases.argocd.values = {
        global.domain = lib.mkForce "argocd-dev.gaslightctf.cooking";
        server.httproute.hostnames = lib.mkForce [ "argocd-dev.gaslightctf.cooking" ];

        global.logging.level = "debug";
      };
    };
}
