{
  perSystem = {...}: {
    treefmt = {
      programs.alejandra.enable = true;

      programs.prettier = {
        enable = true;
        includes = ["*.md" "garnix.yaml"];

        settings = {
          tabWidth = 2;
          printWidth = 100;
        };
      };
    };
  };
}
