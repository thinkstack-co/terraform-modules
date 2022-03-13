module "ad_connector" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/directory_service_ad_connector?ref=v0.8.0"

  alias             = "ad.corp.com"
  customer_dns_ips  = ["10.11.1.100", "10.11.2.100"]
  customer_username = "svc_aws_adconnector"
  description       = "ad.corp.com adconnector"
  name              = "ad.corp.com"
  password          = var.ad_connector_password
  size              = "Small"
  subnet_ids        = [module.vpc.private_subnet.ids]
  tags = {
    created_by  = "Zachary Hill"
    environment = "prod"
    terraform   = "true"
  }
  type   = "ADConnector"
  vpc_id = module.vpc.id
}
