module "aws_ec2_domain_controllers" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_domain_controller"

  vpc_id                 = module.vpc.vpc_id
  key_name               = module.keypair.key_name
  name                   = "aws-dc"
  instance_type          = "t2.small"
  subnet_id              = module.vpc.private_subnet_ids
  ami                    = "ami-ffffffff"
  count                  = 2
  domain_name            = "ad.yourdomain.com"
  vpc_security_group_ids = [module.domain_controller_sg.id]

  tags = {
    terraform         = "true"
    created_by        = "terraform"
    environment       = "prod"
    project           = "core_infrastructure"
    role              = "domain_controller"
    backup            = "true"
    hourly_retention  = "7"
    daily_retention   = "14"
    monthly_retention = "60"
  }
}
