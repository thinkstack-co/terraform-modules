module "domain_controller_sg" {
  source = "../"

  cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  vpc_id      = module.vpc.vpc_id
}
