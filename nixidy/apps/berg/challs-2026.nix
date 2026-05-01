{
  flake.modules.nixidy.challs-2026 = {
    applications.apps.resources.applications.challs-2026.spec = {
      destination = {
        namespace = "berg";
        server = "https://kubernetes.default.svc";
      };

      project = "default";

      source = {
        repoURL = "https://github.com/gaslightctf/challs-2026.git";
        path = ".";

        targetRevision = "prod";

        directory = {
          recurse = true;

          exclude = "template/**/*";
        };
      };

      syncPolicy.automated = {
        prune = true;
        selfHeal = true;
      };
    };
  };
}
