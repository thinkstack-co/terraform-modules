module "app_needs_static_mac_address" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_instance_with_eni"

  name                   = "mac-address-app"
  ami                    = "ami-ffffffff"
  availability_zone      = "us-west-2a"
  count                  = 1
  subnet_id              = module.vpc.private_subnet_ids[0]
  instance_type          = "m4.large"
  key_name               = module.keypair.key_name
  vpc_security_group_ids = ["sg-ffffffff"]
  device_index           = 0
  volume_tags = {
    os_drive    = "c"
    device_name = "/dev/sda1"
    terraform   = "true"
    created_by  = "terraform"
    environment = "prod"
    role        = "app_server"
    backup      = "true"
  }
  tags = {
    terraform        = "true"
    created_by       = "terraform"
    environment      = "prod"
    role             = "app_server"
    backup           = "true"
    hourly_retention = "7"
  }
}
