module "aws_ec2_domain_controllers" {
    source                  = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_domain_controller"

    vpc_id                  = "${module.vpc.vpc_id}"
    key_name                = "${module.keypair.key_name}"
    instance_name_prefix    = "aws-dc"
    instance_type           = "t2.small"
    subnet_id               = "${module.vpc.private_subnet_ids}"
    ami_id                  = "ami-ffffffff"
    number_of_instances     = 2
    domain_name             = "ad.yourdomain.com"
    sg_cidr_blocks          = "${
        list(
        module.vpc.vpc_cidr_block,
        "0.0.0.0/0"
        )
    }"
    tags                    = {
        terraform   = "true"
        created_by  = "terraform"
        environment = "prod"
        project     = "core_infrastructure"
        role        = "domain_controller"
        backup      = "true"
        hourly_retention    = "7"
        daily_retention     = "14"
        monthly_retention   = "60"
    }
}
