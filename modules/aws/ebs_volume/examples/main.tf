module "app_server_d_drive" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/ebs_volume"

  availability_zone = module.vpc.availability_zone[0]
  size              = "50"
  device_name       = "xvdb"
  instance_id       = module.app_server.id[0]
  tags = {
    Name        = "app_server"
    os_drive    = "d"
    device_name = "xvdb"
    terraform   = "yes"
    created_by  = "terraform"
    environment = "prod"
    role        = "app_server"
    backup      = "true"
  }
}
