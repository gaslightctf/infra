{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;

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

            boot_disk.initialize_params.image = "debian-cloud/debian-13";
            metadata.ssh-keys = lib.join "\n" (lib.map (x: "root:${x}") sshKeys);
            metadata_startup_script = ''
              # nixos will have ssh started when it boots
              systemctl stop sshd || true

              echo "rm -rf /old-root/" > /setup.sh

              curl https://codeberg.org/whitequark/nixos-bite/raw/commit/80e06ba28906c15b275f1d7051af1f0073486f89/nixos-bite.sh | NIX_SETUP=/setup.sh bash -s reboot 2>&1 | tee /tmp/bite.log
            '';

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
            };

            connection = {
              type = "ssh";
              user = "root";
              agent = true;

              host = lib.tfRef "self.network_interface.0.access_config.0.nat_ip";
            };
            provisioner.remote-exec.inline = [ "echo $(hostname) ready at $(date -R)" ];
          }
          cfg.extraConfig
          config.custom.instanceExtra
        ]
      )
    ) config.instances;

    output =
      let
        instances = lib.filterAttrs (_: cfg: cfg.enable) config.instances;
      in
      lib.mapAttrs' (name: cfg: {
        name = "${name}_ip";
        value.value = lib.tfRef "google_compute_instance.${name}.network_interface.0.network_ip";
      }) instances
      // lib.mapAttrs' (name: cfg: {
        name = "${name}_ip_public";
        value.value = lib.tfRef "google_compute_instance.${name}.network_interface.0.access_config.0.nat_ip";
      }) instances;

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
