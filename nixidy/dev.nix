{
  flake.modules.nixidy.dev =
    { lib, ... }:
    {
      nixidy.target.rootPath = lib.mkForce "./manifests/dev";

      applications.berg = {
        helm.releases.berg.values = {
          gateway.domain = lib.mkForce "play-dev.gaslightctf.cooking";

          berg = {
            domain = lib.mkForce "api-dev.gaslightctf.cooking";
            redirectUris = lib.mkForce [
              "http://localhost:5000/frontend/oidc-callback"
              "https://play-dev.gaslightctf.cooking/frontend/oidc-callback"
            ];
            postLogoutRedirectUris = lib.mkForce [
              "http://localhost:5000"
              "https://play-dev.gaslightctf.cooking"
            ];

            ctf.start = lib.mkForce "2026-04-25T22:22:30Z";
            ctf.allowAnonymousAccess = lib.mkForce false;

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

        resources.middlewares.berg-api.spec.headers.accessControlAllowOriginList = lib.mkForce [
          "http://localhost:5000"
          "https://play-dev.gaslightctf.cooking"
        ];
      };

      traefik.certs = builtins.mapAttrs (_: v: { dnsNames = lib.mkForce v; }) {
        argocd = [ "argocd-dev.gaslightctf.cooking" ];

        berg-api = [ "api-dev.gaslightctf.cooking" ];
        berg-play = [ "*.play-dev.gaslightctf.cooking" ];

        openobserve = [ "openobserve-dev.gaslightctf.cooking" ];
      };

      applications.argocd.helm.releases.argocd.values = {
        global.domain = lib.mkForce "argocd-dev.gaslightctf.cooking";
        server.httproute.hostnames = lib.mkForce [ "argocd-dev.gaslightctf.cooking" ];
      };

      applications.apps.resources.applications.challs-2026.spec.source.targetRevision =
        lib.mkForce "master";
    };
}
