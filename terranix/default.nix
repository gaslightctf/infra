{
  imports = [./foo.nix];
  resource."terraform_data".hello = {
    provisioner."local-exec" = {
      command = "echo 'Hello World'";
    };
  };
}
