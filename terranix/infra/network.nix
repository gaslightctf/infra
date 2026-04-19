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

  # https://docs.k3s.io/installation/requirements#inbound-rules-for-k3s-nodes
  # resource.google_compute_firewall.k3s-server-server = {
  #   name = "k3s-server-server";
  #   network = lib.tfRef "google_compute_network.kanto.id";
  #
  #   allow = [
  #     {
  #       # embedded etcd
  #       protocol = "tcp";
  #       ports = [
  #         "2379"
  #         "2380"
  #       ];
  #     }
  #   ];
  #
  #   source_tags = [ "server" ];
  #   target_tags = [ "server" ];
  # };
  #
  # resource.google_compute_firewall.k3s-agent-server = {
  #   name = "k3s-agent-server";
  #   network = lib.tfRef "google_compute_network.kanto.id";
  #
  #   allow = [
  #     {
  #       # k3s server
  #       protocol = "tcp";
  #       ports = [ "6443" ];
  #     }
  #   ];
  #
  #   source_ranges = [ pallet-town-cidr ];
  #   target_tags = [ "server" ];
  # };

  resource.google_compute_firewall.k3s-agent-agent = {
    name = "k3s-agent-agent";
    network = lib.tfRef "google_compute_network.kanto.id";

    allow = [
      {
        # cilium vxlan
        protocol = "udp";
        # ports = [ "8472" ];
      }
      {
        # kubelet metrics + API
        protocol = "tcp";
        # ports = [ "10250" ];
      }
    ];

    source_ranges = [ pallet-town-cidr ];
  };
}
