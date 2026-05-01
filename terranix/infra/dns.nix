{ lib, ... }:
let
in
{
  vars.cf_zone_id = { };
  vars.dns_record_suffix = {
    sensitive = false;
  };

  resource.cloudflare_dns_record =
    builtins.mapAttrs
      (
        n:
        {
          name,
          proxied ? false,
        }:
        {
          inherit proxied;
          name = "${name}\${var.dns_record_suffix}";

          zone_id = lib.tfRef "var.cf_zone_id";
          content = lib.tfRef "google_compute_address.kanto-lb.address";
          type = "A";

          ttl = if proxied then 1 else 10 * 60;
        }
      )
      {
        api = {
          name = "api";
          proxied = true;
        };

        argocd = {
          name = "argocd";
          proxied = true;
        };

        openobserve = {
          name = "openobserve";
          proxied = true;
        };

        play-wildcard = {
          name = "*.play";
        };
      };
}
