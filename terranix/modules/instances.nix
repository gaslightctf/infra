{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;

  ips = import ../../data/ips.nix;

  keys = import ../../data/keys.nix;
  sshKeys = keys.users.sportshead.ssh;
in
{
  options = {
    custom.instanceExtra = mkOption {
      type = types.raw;
      default = { };
    };

    instances = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              enable = lib.mkEnableOption name;

              tags = mkOption {
                type = types.listOf types.str;
                default = [ ];
              };

              extraConfig = mkOption {
                type = types.raw;
                default = { };
              };
            };
          }
        )
      );
    };
  };

  config = {
    resource.google_compute_instance = lib.mapAttrs (
      name: cfg:
      assert lib.assertMsg (
        cfg.enable -> builtins.match "^[a-z]([-a-z0-9]*[a-z0-9])$" name != null
      ) "instance name '${name}' does not match the regex '^[a-z]([-a-z0-9]*[a-z0-9])$'";
      lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            inherit name;
            inherit (cfg) tags;

            allow_stopping_for_update = true;

            machine_type = "t2d-standard-4";

            boot_disk.initialize_params = {
              size = 50;
              image = "debian-cloud/debian-13";
            };
            metadata.ssh-keys = lib.join "\n" (lib.map (x: "root:${x}\nnixos-anywhere:${x}") sshKeys);

            shielded_instance_config = {
              enable_secure_boot = false;
              enable_vtpm = false;
              enable_integrity_monitoring = false;
            };

            network_interface = {
              subnetwork = lib.tfRef "google_compute_subnetwork.pallet-town.id";
              access_config.network_tier = "STANDARD";
              access_config = {
                nat_ip = lib.tfRef "google_compute_address.${name}.address";
              };
              network_ip = ips.instances.${name}.local;
              alias_ip_range = {
                ip_cidr_range = ips.instances.${name}.pod-cidr;
                subnetwork_range_name = "k3s-pod";
              };
            };
            can_ip_forward = true;
          }
          cfg.extraConfig
          config.custom.instanceExtra
        ]
      )
    ) config.instances;

    output = lib.mapAttrs' (name: cfg: {
      name = "${name}_ip_public";
      value.value = lib.tfRef "google_compute_instance.${name}.network_interface.0.access_config.0.nat_ip";
    }) (lib.filterAttrs (_: cfg: cfg.enable) config.instances);

    resource.google_compute_address = lib.mapAttrs (
      name: cfg:
      lib.mkIf cfg.enable {
        inherit name;
        address_type = "EXTERNAL";
        network_tier = "STANDARD";
      }
    ) config.instances;

    resource.google_compute_instance_group_membership = lib.mapAttrs (
      name: cfg:
      lib.mkIf cfg.enable {
        instance = lib.tfRef "google_compute_instance.${name}.id";
        instance_group = lib.tfRef "google_compute_instance_group.kanto.id";
      }
    ) config.instances;
  };
}
