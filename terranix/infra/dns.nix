{ lib, ... }:
let
  zone_id = lib.tfRef "var.cf_zone_id";
  content = lib.tfRef "google_compute_address.kanto-lb.address";
  type = "A";
in
{
  vars.cf_zone_id = { };
  vars.dns_record_suffix = {
    sensitive = false;
  };

  resource.cloudflare_dns_record.play = {
    inherit
      zone_id
      content
      type
      ;

    name = "play\${var.dns_record_suffix}";
    proxied = true;
    # managed by cf
    ttl = 1;
  };

  resource.cloudflare_dns_record.chall-root = {
    inherit
      zone_id
      content
      type
      ;

    name = "chall\${var.dns_record_suffix}";
    proxied = false;
    # 10 mins
    ttl = 10 * 60;
  };

  resource.cloudflare_dns_record.chall-wildcard = {
    inherit
      zone_id
      content
      type
      ;

    name = "*.chall\${var.dns_record_suffix}";
    proxied = false;
    # 10 mins
    ttl = 10 * 60;
  };
}
