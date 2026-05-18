{
  flake.modules.nixidy.challs-2026 = {
    applications.apps.resources.applications.challs-2026.spec = {
      destination = {
        namespace = "berg";
        server = "https://kubernetes.default.svc";
      };

      project = "default";

      source = {
        repoURL = "https://github.com/gaslightctf/challs-2026-manifests.git";
        path = ".";

        targetRevision = "prod";

        directory = {
          recurse = true;
        };
      };

      syncPolicy.automated = {
        prune = true;
        selfHeal = true;
      };
    };
  };
}
