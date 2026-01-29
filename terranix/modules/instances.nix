{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;

  keys = import ../../data/keys.nix;
  sshKeys = lib.splitString "\n" (lib.trim keys.users.sportshead.ssh);
in {
  options = {
    custom.instance_extra = mkOption {
      type = types.raw;
      default = {};
    };

    instances = mkOption {
      type = types.attrsOf (
        types.submodule ({name, ...}: {
          options = {
            enable = lib.mkEnableOption name;

            tags = mkOption {
              type = types.listOf types.str;
              default = [];
            };

            extraConfig = mkOption {
              type = types.attrsOf types.anything;
              default = {};
            };
          };
        })
      );
    };
  };

  config = {
    resource.google_compute_instance = lib.mapAttrs (name: cfg:
      assert lib.assertMsg (cfg.enable -> builtins.match "^[a-z]([-a-z0-9]*[a-z0-9])$" name != null)
      "instance name '${name}' does not match the regex '^[a-z]([-a-z0-9]*[a-z0-9])$'";
        lib.mkIf cfg.enable (lib.mkMerge [
          {
            inherit name;
            inherit (cfg) tags;

            allow_stopping_for_update = true;

            machine_type = "t2d-standard-4";

            boot_disk.initialize_params.image = "debian-cloud/debian-12";
            metadata.ssh-keys = lib.join "\n" (lib.map (x: "root:${x}") sshKeys);
            metadata_startup_script = ''
              # nixos will have ssh started when it boots
              systemctl stop sshd || true

              curl https://raw.githubusercontent.com/elitak/nixos-infect/7563801d3ae68c975e4027f4e31a3906dca95f30/nixos-infect | PROVIDER=gcp NIX_CHANNEL=nixos-25.11 bash 2>&1 | tee /tmp/infect.log
            '';

            network_interface = {
              subnetwork = lib.tfRef "google_compute_subnetwork.pallet-town.id";
              access_config.network_tier = "STANDARD";
            };

            connection = {
              type = "ssh";
              user = "root";
              agent = true;

              host = lib.tfRef "self.network_interface.0.access_config.0.nat_ip";
            };
            provisioner.remote-exec.inline = ["echo $(hostname) ready at $(date -R)"];
          }
          cfg.extraConfig
          config.custom.instance_extra
        ]))
    config.instances;

    output = let
      instances = lib.filterAttrs (_: cfg: cfg.enable) config.instances;
    in
      lib.mapAttrs' (
        name: cfg: {
          name = "${name}_ip";
          value.value = lib.tfRef "google_compute_instance.${name}.network_interface.0.network_ip";
        }
      )
      instances
      // lib.mapAttrs' (
        name: cfg: {
          name = "${name}_ip_public";
          value.value = lib.tfRef "google_compute_instance.${name}.network_interface.0.access_config.0.nat_ip";
        }
      )
      instances;
  };
}
