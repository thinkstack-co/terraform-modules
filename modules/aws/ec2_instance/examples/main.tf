module "sql_server" {
    source                 = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_instance?ref=v0.4.5"
    
    ami                    = "ami-ffffffff"
    availability_zone      = "${module.vpc.availability_zone[0]}"
    count                  = 1
    ebs_optimized          = true
    instance_type          = "m4.4xlarge"
    key_name               = "${module.keypair.key_name}"
    monitoring             = true
    name                   = "sql"
    private_ip             = ""
    root_volume_type       = "gp2"
    root_volume_size       = "100"    
    subnet_id              = "${module.vpc.private_subnet_ids[0]}"
    vpc_security_group_ids = ["sg-ffffffff"]
    volume_tags            = {
        os_drive    = "c"
        device_name = "/dev/sda1"
        terraform   = "yes"
        created_by  = "terraform"
        environment = "prod"
        role        = "sql"
        backup      = "true"
    }
    tags                    = {
        terraform        = "yes"
        created_by       = "terraform"
        environment      = "prod"
        role             = "sql"
        backup           = "true"
        hourly_retention = "7"
    }
}
