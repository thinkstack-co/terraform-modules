module "aws_prod_cato" {
  source            = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_instance"

  ami               = "ami-023xxdfb5fdsxfx1e"
  availability_zone = module.vpc.availability_zone[0]
  key_name          = module.keypair.key_name
  instance_type     = "c5.large"
  mgmt_subnet_id    = module.vpc.mgmt_subnet_ids
  public_subnet_id  = module.vpc.public_subnet_ids
  private_subnet_id = module.vpc.private_subnet_ids
  vpc_id            = module.vpc.vpc_id

  tags              = {
    terraform   = "true"
    created_by  = "Zachary Hill"
    environment = "prod"
    project     = "aws_poc"
    backup      = "true"
    role        = "cato_sdwan"
  }
}
