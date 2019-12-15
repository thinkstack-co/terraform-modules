terraform {
  required_version = ">= 0.12.0"
}

resource "aws_key_pair" "deployer_key" {
    key_name_prefix =   var.key_name_prefix
    public_key      =   var.public_key
}
