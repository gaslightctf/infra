{ lib, ... }:
let
  ips = import ../../data/ips.nix;

  inherit (ips) pallet-town-cidr pod-cidr;
in
{
  resource.google_compute_network.kanto = {
    name = "kanto";
    auto_create_subnetworks = false;
  };

  resource.google_compute_subnetwork.pallet-town = {
    name = "pallet-town";
    network = lib.tfRef "google_compute_network.kanto.id";

    ip_cidr_range = pallet-town-cidr;

    secondary_ip_range = [
      {
        range_name = "k3s-pod";
        ip_cidr_range = pod-cidr;
      }
    ];
  };

  resource.google_compute_firewall.external-ssh = {
    name = "external-ssh";
    network = lib.tfRef "google_compute_network.kanto.id";

    allow = [
      {
        protocol = "tcp";
        ports = [ "22" ];
      }
    ];

    source_ranges = [ "0.0.0.0/0" ];
  };

  # TODO: stricter rules with cilium host firewall
  resource.google_compute_firewall.k3s-internal = {
    name = "k3s-internal";
    network = lib.tfRef "google_compute_network.kanto.id";

    allow = [
      { protocol = "udp"; }
      { protocol = "tcp"; }
      { protocol = "icmp"; }
    ];

    source_ranges = [
      pallet-town-cidr
      pod-cidr
    ];
  };
}
