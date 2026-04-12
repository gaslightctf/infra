{
  flake.modules.nixidy.dev =
    { lib, ... }:
    {
      nixidy.target.rootPath = lib.mkForce "./manifests/dev";
    };
}
