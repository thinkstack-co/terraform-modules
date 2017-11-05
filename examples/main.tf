terraform {
  backend "s3" {
    bucket         = "thinkstack-terraform"
    key            = "solarity/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform_state_lock"
    acl            = "private"
  }
}

provider "aws" {
    region  = "us-west-2"
    profile = "solarity"
}

data "terraform_remote_state" "solarity" {
  backend       = "s3"
  config {
    bucket      = "thinkstack-terraform"
    key         = "solarity/terraform.tfstate"
    region      = "us-east-1"
    encrypt     = true
    acl         = "private"
  }
}

##########################################################
# IAM Modules
##########################################################

module "iam_groups" {
    source          = "./global/iam/iam_groups"

    mfa_policy_arn  = "${module.mfa_self_serve_policy.mfa_policy_arn}"
}

module "ebs_backup_policy" {
    source              = "./global/iam/iam_policies/ebs_backup"
    
    policy_name         = "ebs_backup_policy"
    policy_description  = "Policy which allows backing up of ec2 instance volumes and adding cloudwatch logs"
    policy              = "${file("global/iam/iam_policies/ebs_backup/ebs-backup-role-policy.json")}"
}

module "ebs_backup_role" {
    source              = "./global/iam/iam_roles"

    role_name           = "ebs_backup_role"
    role_description    = "Role used for lambda to take EC2 EBS backups."
    trust_policy        = "${file("global/iam/iam_roles/ebs_backup_role/ebs-backup-trust-policy.json")}"
    policy_arn          = "${module.ebs_backup_policy.policy_arn}"
}

module "mfa_self_serve_policy" {
    source  = "./global/iam/iam_policies/mfa_self_serve"
}

module "primary_kms_key" {
    source  = "./modules/aws_kms"
}

module "sms_connector_user" {
    source          = "./global/iam/iam_users"

    iam_user_name   = "svc_sms_connector"
    
}

##########################################################
# S3 Modules
##########################################################

module "s3_admin_bucket" {
    source = "./modules/aws_s3"

    s3_bucket_prefix    =   "solarity-admin-"
    s3_bucket_region    =   "us-west-2"
    s3_bucket_acl       =   "private"
}

##########################################################
# VPC Modules
##########################################################

module "vpc" {
    source                      = "./modules/aws_vpc"

    name                        = "terraform"
    vpc_cidr                    = "10.100.0.0/16"
    azs                         = ["us-west-2a", "us-west-2b"]
    private_subnets_list        = ["10.100.1.0/24", "10.100.2.0/24"]
    public_subnets_list         = ["10.100.201.0/24", "10.100.202.0/24"]
    public_propagating_vgws     = ["${module.north_vpn.vpn_gateway_id}"]
    private_propagating_vgws    = ["${module.north_vpn.vpn_gateway_id}"]
    fw_network_interface_id     = "${module.aws_ec2_fortigate_fw.fw_private_nic_id}"
    tags                    = {
        terraform   = "yes"
        created_by  = "terraform"
        environment = "prod"
    }
}

module "north_vpn" {
    source                  = "./modules/aws_vpn"

    vpc_id                  = "${module.vpc.vpc_id}"
    name                    = "north_vpn"
    bgp_asn                 = 65001
    ip_address              = "52.144.56.98"
    tags                    = {
        terraform   = "yes"
        created_by  = "terraform"
        environment = "prod"
    }
}

module "vpn_route_10_0_0_0" {
    source                  = "./modules/aws_vpn_route"

    vpn_connection_id       = "${module.north_vpn.vpn_connection_id}"
    vpn_route_cidr_block    = "10.0.0.0/8"
}

module "vpn_route_172_16_0_0" {
    source                  = "./modules/aws_vpn_route"

    vpn_connection_id       = "${module.north_vpn.vpn_connection_id}"
    vpn_route_cidr_block    = "172.16.0.0/16"
}

module "vpn_route_192_168_0_0" {
    source                  = "./modules/aws_vpn_route"

    vpn_connection_id       = "${module.north_vpn.vpn_connection_id}"
    vpn_route_cidr_block    = "192.168.0.0/16"
}

##########################################################
# CloudTrail Modules
##########################################################

module "cloudtrail" {
    source              = "./modules/aws_cloudtrail"
    
    s3_bucket_prefix    =   "solarity-cloudtrail-"
    s3_bucket_region    =   "us-west-2"
    s3_bucket_acl       =   "private"
    s3_mfa_delete       =   true
    # cloudtrail_kms_key  =   "${module.primary_kms_key.kms_key_arn}"
}

##########################################################
# Lambda Modules
##########################################################

module "ec2_backup" {
    source                  = "./modules/aws_lambda"

    lambda_description      = "EC2 backup function"
    lambda_filename         = "./lambda_functions/lambda_ec2_backup_v1.zip"
    source_code_hash        = "${base64sha256(file("./lambda_functions/lambda_ec2_backup_v1.zip"))}"
    lambda_function_name    = "ec2_backup"
    lambda_role             = "${module.ebs_backup_role.arn}"
    lambda_handler          = "lambda_ec2_backup.lambda_handler"
    lambda_timeout          = 60
    statement_id            = "ec2_backup"
    source_arn              = "${module.hourly_lambda_event.arn}"
}

module "ec2_backup_cleanup" {
    source                  = "./modules/aws_lambda"
    
    lambda_description      = "EC2 backup cleanup function"
    lambda_filename         = "./lambda_functions/lambda_backup_cleanup_script.zip"
    source_code_hash        = "${base64sha256(file("./lambda_functions/lambda_backup_cleanup_script.zip"))}"
    lambda_function_name    = "ec2_backup_cleanup"
    lambda_role             = "${module.ebs_backup_role.arn}"
    lambda_handler          = "lambda_backup_cleanup_script.lambda_handler"
    lambda_timeout          = 180
    statement_id            = "ec2_backup_cleanup"
    source_arn              = "${module.daily_lambda_event.arn}"
}

module "hourly_lambda_event" {
    source              = "./modules/aws_cloudwatch"
    
    name                = "hourly-lambda-trigger"
    description         = "Event which triggers once per hour"
    schedule_expression = "rate(1 hour)"
    event_target_arn    = "${module.ec2_backup.arn}"
}

module "daily_lambda_event" {
    source  = "./modules/aws_cloudwatch"

    name                = "daily-lambda-trigger"
    description         = "Event which triggers once per day"
    schedule_expression = "rate(1 day)"
    event_target_arn    = "${module.ec2_backup_cleanup.arn}"
}

##########################################################
# Security Group Modules
##########################################################



##########################################################
# EC2 Modules
##########################################################

module "keypair" {
    source          = "./modules/aws_keypair"
    
    key_name_prefix = "terraform_keypair_01"
    public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAmS8RrF5ZifrGUiNqQEM8uTgdGp9E88zgJWQXHpo0cN1VSAjcbgNDhqKcs2eLaD+0g/NsiKz+bLfOlsdWXtsDm5bC1AZaUpx/BKJkfvO+lnPZrAp59H4GJCeQQthkYfYyIjMojW0Wp03VcE/NjkMJdnD7xfuu3GX/zbWQOqlmBBstxXRg7F7GaGc0/lGOd+9p0JoOlnfQxpfQAyAddE9lALPJMzuVvV4wdYN2wxnIUGtEcn4FydbEnbfAwm4CB7xmp3yxwIbxbiHqNMWcyg+FNE2oCTBGtZL8AMy5xqHZR/yJnTL/SHh0mvbKiQaiajuDx+XhGbsHH2Uhu6jGavFGt/ofut3tyd6NMzB6HSatA0RJbUV2BDpaUWp4NQtGugyF8VVg7GV2PHsquH/veW4z7mjnajIH9Bb+pUEAmHFvjkg9RB5dF2GnaOZInt4pafwGXnrHgWebwyeTfkjYZCs7EargvT0SA1WjsY09XjGbm+yD5wttGX0m+wP4pmZW2KkVJUwHxZnsNYAoOqpC0GfFE+O7Ah2uK4xfKLrdmHSqTnyU0SGlrE7eVc6qCwJyiBTebyNxdranRCQjxUdN0D8QceaKKaHQzh81Ib3VdKofepZz8vXnHZKhx7KMxE6h1+JZdPKLfg11cYa2xTswCl/zl9VKMyFdv/Xkp4NuAfJ7uiE="
}

module "aws_ec2_domain_controllers" {
    source                  = "./modules/aws_ec2_domain_controller"

    vpc_id                  = "${module.vpc.vpc_id}"
    key_name                = "${module.keypair.key_name}"
    instance_name_prefix    = "aws_dc"
    instance_type           = "t2.small"
    subnet_id               = "${module.vpc.private_subnet_ids}"
    ami_id                  = "ami-b672b2ce"
    number_of_instances     = 2
    domain_name             = "solaritycu.org"
    sg_cidr_blocks          = "${
        list(
        module.vpc.vpc_cidr_block,
        "0.0.0.0/0"
        )
    }"
    tags                    = {
        terraform   = "yes"
        created_by  = "terraform"
        environment = "prod"
        role        = "domain_controller"
        backup      = "true"
        retention   = "14"
    }
}

module "aws_ec2_fortigate_fw" {
    source                  = "./modules/aws_fortigate_firewall"

    vpc_id                  = "${module.vpc.vpc_id}"
    number_of_instances     = 2
    public_subnet_id        = "${module.vpc.public_subnet_ids}"
    private_subnet_id       = "${module.vpc.private_subnet_ids}"
    ami_id                  = "ami-0f819276"
    instance_type           = "m3.medium"
    key_name                = "${module.keypair.key_name}"
    instance_name_prefix    = "aws_fw"

    tags    = {
        terraform   = "yes"
        created_by  = "terraform"
        environment = "prod"
        role        = "fortigate_firewall"
        backup      = "true"
    }
}

module "av-yakima" {
    source                  = "./modules/aws_ec2_windows_migrated_instance"

    instance_name_prefix    = "av_yakima"
    ami_id                  = "ami-592de221"
    number_of_instances     = 1
    subnet_id               = "${module.vpc.private_subnet_ids[0]}"
    instance_type           = "t2.medium"
    key_name                = "${module.keypair.key_name}"
    security_group_ids      = "sg-0acbb377"
    /*root_volume_size        = "80"
    ebs_volume_size         = "100"*/

    tags                    = {
        terraform   = "yes"
        created_by  = "terraform"
        environment = "prod"
        role        = "antivirus"
        backup      = "true"
        retention   = "7"
    }
}

module "opcon" {
    source = "./modules/aws_ec2_windows_migrated_instance"
    
    instance_name_prefix    = "opcon"
    ami_id                  = "ami-7932fd01"
    number_of_instances     = 1
    subnet_id               = "${module.vpc.private_subnet_ids[0]}"
    instance_type           = "t2.large"
    key_name                = "${module.keypair.key_name}"
    security_group_ids      = "sg-deff84a3"

    tags                    = {
        terraform   = "yes"
        created_by  = "terraform"
        environment = "prod"
        role        = "batch_processor"
        backup      = "true"
        retention   = "30"
    }    
}
