module "aws_ec2_fortigate_fw" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/fortigate_firewall"

  vpc_id               = module.vpc.vpc_id
  number_of_instances  = 2
  public_subnet_id     = module.vpc.public_subnet_ids
  private_subnet_id    = module.vpc.private_subnet_ids
  ami_id               = "ami-ffffffff"
  instance_type        = "m3.medium"
  key_name             = module.keypair.key_name
  instance_name_prefix = "aws_fw"

  tags = {
    terraform         = "true"
    created_by        = "terraform"
    environment       = "prod"
    project           = "core_infrastructure"
    role              = "fortigate_firewall"
    backup            = "true"
    hourly_retention  = "7"
    daily_retention   = "14"
    monthly_retention = "60"
  }
}
