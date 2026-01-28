{
  lib,
  config,
  ...
}: let
  keys = import ../../data/keys.nix;
  sshKeys = lib.splitString "\n" (lib.trim keys.users.sportshead.ssh);
in {
  vars.hello_message = {sensitive = false;};

  instances.eevee = {
    enable = true;
    bastion = true;
  };

  instances.vaporeon.enable = true;
  instances.jolteon.enable = true;
}
