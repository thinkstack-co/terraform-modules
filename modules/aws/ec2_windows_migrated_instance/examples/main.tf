module "migrated_instance" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_windows_migrated_instance"

  instance_name_prefix = "migrated_app"
  ami_id               = "ami-ffffffff"
  number_of_instances  = 1
  subnet_id            = module.vpc.private_subnet_ids[0]
  instance_type        = "m4.large"
  key_name             = module.keypair.key_name
  security_group_ids   = "sg-ffffffff"

  tags = {
    terraform        = "true"
    created_by       = "terraform"
    environment      = "prod"
    role             = "application_xtender_sql"
    backup           = "true"
    hourly_retention = "7"
  }
}
