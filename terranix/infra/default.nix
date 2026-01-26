{lib, ...}: {
  vars.hello_message = {};

  resource.terraform_data.hello = {
    provisioner.local-exec = {
      command = "echo 'Hello \${var.hello_message}'";
    };
  };
}
