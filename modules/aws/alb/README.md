Application Load Balancer Module
=================

This module sets up an Application Load Balancer with the parameters specified.


## Usage
        module "app_server" {
        source                 = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_instance"
            
        name  
        
        tags                   = {
            terraform   = "yes"
            created_by  = "terraform"
            environment = "prod"
            role        = "app_server"
            backup      = "true"
            hourly_retention    = "7"
        }
    }

    module "app_server_d_drive" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/ebs_volume"

        availability_zone   = module.vpc.availability_zone[0]
        size                = "50"
        device_name         = "xvdb"
        instance_id         = module.app_server.id[0]
        tags                = {
            Name        = "app_server"
            os_drive    = "d"
            device_name = "xvdb"
            terraform   = "yes"
            created_by  = "terraform"
            environment = "prod"
            role        = "app_server"
            backup      = "true"
        }
    }

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs_bucket"></a> [access\_logs\_bucket](#input\_access\_logs\_bucket) | (Required) The S3 bucket name to store the logs in. | `string` | n/a | yes |
| <a name="input_access_logs_enabled"></a> [access\_logs\_enabled](#input\_access\_logs\_enabled) | (Optional) Boolean to enable / disable access\_logs. Defaults to false, even when bucket is specified. | `string` | `true` | no |
| <a name="input_access_logs_prefix"></a> [access\_logs\_prefix](#input\_access\_logs\_prefix) | (Optional) The S3 bucket prefix. Logs are stored in the root if not configured. | `string` | `"alb-log"` | no |
| <a name="input_enable_cross_zone_load_balancing"></a> [enable\_cross\_zone\_load\_balancing](#input\_enable\_cross\_zone\_load\_balancing) | (Optional) If true, cross-zone load balancing of the load balancer will be enabled. This is a network load balancer feature. Defaults to false. | `string` | `false` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | (Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `string` | `false` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | (Optional) Indicates whether HTTP/2 is enabled in application load balancers. Defaults to true. | `string` | `true` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | (Optional) The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60. | `string` | `60` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | (Optional) If true, the LB will be internal. | `string` | `false` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | (Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack | `string` | `"ipv4"` | no |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | (Optional) The type of load balancer to create. Possible values are application or network. The default value is application. | `string` | `"application"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the LB. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen. If not specified, Terraform will autogenerate a name beginning with tf-lb. | `string` | n/a | yes |
| <a name="input_number"></a> [number](#input\_number) | (Optional) the number of resources to create | `string` | `1` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | (Required) A list of security group IDs to assign to the LB. Only valid for Load Balancers of type application. | `list(string)` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | (Optional) A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type network. Changing this value for load balancers of type network will force a recreation of the resource. | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->