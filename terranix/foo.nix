{
  resource."terraform_data".hello2 = {
    provisioner."local-exec" = {
      command = "echo 'Hello World 2'";
    };
  };
}
