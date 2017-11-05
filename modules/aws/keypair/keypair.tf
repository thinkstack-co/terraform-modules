resource "aws_key_pair" "deployer_key" {
    key_name_prefix =   "${var.key_name_prefix}"
    public_key      =   "${var.public_key}"
}
