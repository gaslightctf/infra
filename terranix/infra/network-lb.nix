{ lib, ... }:
let
  ports = {
    https = 443;
    chall-https = 1337;
    chall-tls = 31337;
  };
in
{
  resource.google_compute_instance_group.kanto = {
    name = "kanto";
    network = lib.tfRef "google_compute_network.kanto.id";

    named_port = lib.mapAttrsToList (name: port: {
      inherit name port;
    }) ports;
  };

  resource.google_compute_address.kanto-lb = {
    name = "kanto-lb";
    network_tier = "STANDARD";
    address_type = "EXTERNAL";
  };
  output.kanto_lb_ip.value = lib.tfRef "google_compute_address.kanto-lb.address";

  resource.google_compute_region_health_check.kanto-lb = {
    name = "kanto-lb";

    https_health_check = {
      port = 443;
    };

    log_config.enable = true;
  };

  resource.google_compute_region_backend_service = lib.mapAttrs' (name: port: {
    name = "kanto-backend-${name}";
    value = {
      name = "kanto-backend-${name}";
      protocol = "TCP";
      port_name = name;
      load_balancing_scheme = "EXTERNAL";

      health_checks = [ (lib.tfRef "google_compute_region_health_check.kanto-lb.id") ];
      lifecycle.replace_triggered_by = [ "google_compute_region_health_check.kanto-lb" ];

      backend = [
        {
          group = lib.tfRef "google_compute_instance_group.kanto.id";
          balancing_mode = "CONNECTION";
        }
      ];
    };
  }) ports;

  resource.google_compute_forwarding_rule = lib.mapAttrs' (name: port: {
    name = "kanto-fwd-${name}";
    value = {
      name = "kanto-fwd-${name}";
      ip_protocol = "TCP";
      ip_address = lib.tfRef "google_compute_address.kanto-lb.id";
      port_range = port;
      backend_service = lib.tfRef "google_compute_region_backend_service.kanto-backend-${name}.id";
      network_tier = lib.tfRef "google_compute_address.kanto-lb.network_tier";
    };
  }) ports;

  data.cloudflare_ip_ranges.ips = { };
  resource.google_compute_firewall.kanto-lb-https = {
    name = "kanto-lb-https";
    network = lib.tfRef "google_compute_network.kanto.id";

    allow = [
      {
        protocol = "tcp";
        ports = [ "443" ];
      }
    ];

    source_ranges = lib.tfRef "data.cloudflare_ip_ranges.ips.ipv4_cidrs";
  };

  resource.google_compute_firewall.kanto-lb-chall = {
    name = "kanto-lb-chall";
    network = lib.tfRef "google_compute_network.kanto.id";

    allow = [
      {
        protocol = "tcp";
        ports = [
          "1337"
          "31337"
        ];
      }
    ];

    source_ranges = [ "0.0.0.0/0" ];
  };

  data.google_netblock_ip_ranges.hcs = {
    range_type = "health-checkers";
  };
  resource.google_compute_firewall.kanto-lb-https-healthcheck = {
    name = "kanto-lb-https-healthcheck";
    network = lib.tfRef "google_compute_network.kanto.id";

    allow = [
      {
        protocol = "tcp";
        ports = [ "443" ];
      }
    ];

    # https://docs.cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges
    # source_ranges = [
    #   "35.191.0.0/16"
    #   "209.85.152.0/22"
    #   "209.85.204.0/22"
    # ];
    source_ranges = lib.tfRef "data.google_netblock_ip_ranges.hcs.cidr_blocks_ipv4";
  };
}
