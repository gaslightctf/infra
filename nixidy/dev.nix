{ inputs, ... }:
{
  flake.modules.nixidy.dev =
    { lib, ... }:
    {
      nixidy.target.rootPath = lib.mkForce "./manifests/dev";

      applications.berg.helm.releases.berg.chart = lib.mkForce "${inputs.berg}/charts/berg";
      applications.berg.helm.releases.berg.values = {
        gateway.domain = lib.mkForce "play-dev.gaslightctf.cooking";

        berg.image.tag = "5.13.4";
        frontend.image.tag = "5.13.4";
        handout.image.tag = "5.13.4";

        berg = {
          domain = lib.mkForce "play-dev.gaslightctf.cooking";

          # TODO: testing
          ctf.allowAnonymousAccess = lib.mkForce true;

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

      applications.traefik.resources.certificates.play-gaslightctf-cooking.spec.dnsNames = lib.mkForce [
        "play-dev.gaslightctf.cooking"
        "*.play-dev.gaslightctf.cooking"
      ];
    };
}
