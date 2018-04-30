################
# Simple Example
################
module "public_ip" {
    source   = "github.com/thinkstack-co/terraform-modules//modules/aws/eip"
    
    instance = "${module.web_server.id}"
    vpc      = true
}

################
# Example of associating the EIP with a network interface
################

module "website_eip" {
    source            = "github.com/thinkstack-co/terraform-modules//modules/aws/eip"
    
    network_interface = "${module.fw.private_nic.id}"
    vpc               = true
}
