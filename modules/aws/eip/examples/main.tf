################
# Simple Example
################
module "public_ip" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/eip"

  instance = module.web_server.id[0]
  vpc      = true
}

################
# Example of associating the EIP with a network interface
################

module "website_eip" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/eip"

  associate_with_private_ip = "10.11.201.20"
  network_interface         = module.fw.network_interface_id[0]
  vpc                       = true
}
