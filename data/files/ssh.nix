{ self, lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      INSTANCE-OUTPUT-SUFFIX = "_ip_public";
      getInstances =
        xs:
        map (lib.removeSuffix INSTANCE-OUTPUT-SUFFIX)
        <| builtins.filter (lib.hasSuffix INSTANCE-OUTPUT-SUFFIX)
        <| builtins.attrNames xs;

      devOutputs = import "${self}/data/tf-output/dev.nix";
      devInstances = getInstances devOutputs;

      prodOutputs = import "${self}/data/tf-output/prod.nix";
      prodInstances = getInstances prodOutputs;

      keys = import "${self}/data/keys.nix";

      knownHosts =
        lib.concatLines
        <|
          (map (n: "${devOutputs."${n}${INSTANCE-OUTPUT-SUFFIX}".value} ${keys.dev.${n}.ssh}") devInstances)
          ++ (map (
            n: "${prodOutputs."${n}${INSTANCE-OUTPUT-SUFFIX}".value} ${keys.prod.${n}.ssh}"
          ) prodInstances);

      sshConfig =
        lib.concatLines
        <|
          [ "UserKnownHostsFile \${PRJ_ROOT}/data/ssh/known_hosts" ]
          ++ (map (n: ''
            Host dev-${n}
              User root
              HostName ${devOutputs."${n}${INSTANCE-OUTPUT-SUFFIX}".value}
          '') devInstances)
          ++ (map (n: ''
            Host prod-${n}
              User root
              HostName ${prodOutputs."${n}${INSTANCE-OUTPUT-SUFFIX}".value}
          '') prodInstances);
    in
    {
      files.files = [
        {
          path_ = "data/ssh/config";
          drv = pkgs.writers.writeText "ssh-config" sshConfig;
        }
        {
          path_ = "data/ssh/known_hosts";
          drv = pkgs.writers.writeText "known_hosts" knownHosts;
        }
      ];
    };
}
