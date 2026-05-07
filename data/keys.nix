rec {
  users = {
    sportshead = {
      age = [
        "age1tag1qw6cx6k7s34zt378mgwlmcy4jq4jdzgs4auuwlugyhx8td59wg96q8kyajc" # v1.mbair.se
        "age1chacvhtf5y0vjvh7a762780t84846h8hl72wskjcr99a3qjylgxse30hdf" # backup
      ];
      ssh = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEaYXcKUUKYJ30yJainnKRvVrY4y6nxwktKSx7e9Iu9pGpNwsFuKPBffOPMBrJvO8W5qWHEf2UKcaZkhhtssD3A= v1.mbair.se@sportshead.dev"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCok3Ub3E5e2jApMdYYiNuLkk3XZDODQRVj0iIRjh+9gbxgMg9U4QqMx2bVLzgM3IIDN3VyPK8k8DWG0zyNoiNA= v5.iphone.se@sportshead.dev"
      ];
    };
  };

  dev = import ./keys.dev.nix;
  prod = import ./keys.prod.nix;

  devServers = [
    dev.rayquaza
    dev.kyogre
    dev.groudon
  ];
  prodServers = [ ];
}
