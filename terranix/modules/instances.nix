{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;

  keys = import ../../data/keys.nix;
  sshKeys = lib.splitString "\n" (lib.trim keys.users.sportshead.ssh);

  bastions = lib.attrNames (lib.filterAttrs (_: cfg: cfg.enable && cfg.bastion) config.instances);
  bastion = builtins.elemAt bastions 0;
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

            hostname = mkOption {
              type = types.str;
              default = name;
            };

            tags = mkOption {
              type = types.listOf types.str;
              default = [];
            };

            bastion = mkOption {
              type = types.bool;
              default = false;
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

            tags = cfg.tags ++ lib.optional cfg.bastion "bastion";

            machine_type = "t2d-standard-4";

            boot_disk.initialize_params.image = "debian-cloud/debian-12";

            network_interface.network = "default";

            metadata.ssh-keys = lib.join "\n" (lib.map (x: "root:${x}") sshKeys);

            metadata_startup_script = ''
              # nixos will have ssh started when it boots
              systemctl stop sshd || true

              curl https://raw.githubusercontent.com/elitak/nixos-infect/7563801d3ae68c975e4027f4e31a3906dca95f30/nixos-infect | PROVIDER=gcp NIX_CHANNEL=nixos-25.11 bash 2>&1 | tee /tmp/infect.log
            '';

            connection = {
              type = "ssh";
              user = "root";
              agent = true;
            };
            provisioner.remote-exec.inline = ["echo $(hostname) ready at $(date -R)"];
          }
          (
            if cfg.bastion
            then {
              network_interface.access_config = {
                network_tier = "STANDARD";
              };

              connection = {
                host = lib.tfRef "self.network_interface.0.access_config.0.nat_ip";
              };
            }
            else {
              connection = {
                host = lib.tfRef "self.network_interface.0.network_ip";
                bastion_host = lib.tfRef "google_compute_instance.${bastion}.network_interface.0.access_config.0.nat_ip";
              };
            }
          )
          cfg.extraConfig
          config.custom.instance_extra
        ]))
    config.instances;

    output =
      lib.mapAttrs' (
        name: cfg: {
          name = "${name}_ip";
          value.value = lib.tfRef "google_compute_instance.${name}.network_interface.0.network_ip";
        }
      )
      (lib.filterAttrs (_: cfg: cfg.enable) config.instances)
      // lib.mapAttrs' (
        name: cfg: {
          name = "${name}_ip_public";
          value.value = lib.tfRef "google_compute_instance.${name}.network_interface.0.access_config.0.nat_ip";
        }
      )
      (lib.filterAttrs (_: cfg: cfg.enable && cfg.bastion) config.instances);
  };
}
