# EC2 Domain Controller Module
Creates an EC2 instance, status checks, and optional DHCP option sets.

# Usage
    module "domain_controllers" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_domain_controller"

        vpc_id                 = module.vpc.vpc_id
        ami                    = lookup(var.aws_amis, var.aws_prod_region)
        encrypted              = true
        key_name               = module.keypair.key_name
        name                   = "aws_prod_dc"
        instance_type          = "t3a.large"
        subnet_id              = module.vpc.private_subnet_ids
        iam_instance_profile   = "ssm-service-role"
        number                  = 2
        domain_name            = "example.local"
        private_ip             = ["10.11.1.100", "10.11.2.100"]
        vpc_security_group_ids = [module.domain_controller_sg.id]
        region                 = var.aws_prod_region

        tags = {
            terraform         = "true"
            created_by        = "terraform"
            environment       = "prod"
            project           = "core_infrastructure"
            role              = "domain_controller"
            backup            = "true"
            ssm_update        = "true"
        }
    }

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_instance.ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_vpc_dhcp_options.dc_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.dc_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | The AMI to use | `any` | n/a | yes |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The AZ to start the instance in | `string` | `""` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name suffix to add to DHCP DNS | `any` | n/a | yes |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| <a name="input_enable_dhcp_options"></a> [enable\_dhcp\_options](#input\_enable\_dhcp\_options) | boolean to determine if DHCP options are enabled | `bool` | `true` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | (Optional) Enable volume encryption. (Default: false). Must be configured to perform drift detection. | `bool` | `true` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. | `string` | `""` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | Shutdown behavior for the instance | `string` | `""` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Select the instance type. Set in main.tf | `string` | `"t2.medium"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | keypair name to use for ec2 instance deployment. Keypairs are used to obtain the username/password | `string` | `""` | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the instance | `any` | n/a | yes |
| <a name="input_number"></a> [number](#input\_number) | number of instances to make | `number` | `2` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | The Placement Group to start the instance in | `string` | `""` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP address to associate with the instance in a VPC | `any` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Required) VPC Region the resources exist in | `string` | n/a | yes |
| <a name="input_root_delete_on_termination"></a> [root\_delete\_on\_termination](#input\_root\_delete\_on\_termination) | (Optional) Whether the volume should be destroyed on instance termination (Default: true) | `string` | `true` | no |
| <a name="input_root_iops"></a> [root\_iops](#input\_root\_iops) | (Optional) The amount of provisioned IOPS. This is only valid for volume\_type of io1, and must be specified if using that type | `string` | `""` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | (Optional) The size of the volume in gigabytes. | `string` | `"100"` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | (Optional) The type of volume. Can be standard, gp2, gp3 or io1. (Default: standard) | `string` | `"gp3"` | no |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. | `bool` | `true` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The VPC subnet the instance(s) will be assigned. Set in main.tf | `list` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map` | `{}` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host. | `string` | `"default"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to provide when launching the instance | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC id to add the security group | `any` | n/a | yes |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | A list of security group IDs to associate with | `list` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dhcp_options_id"></a> [dhcp\_options\_id](#output\_dhcp\_options\_id) | n/a |
| <a name="output_ec2_instance_id"></a> [ec2\_instance\_id](#output\_ec2\_instance\_id) | n/a |
| <a name="output_ec2_instance_priv_ip"></a> [ec2\_instance\_priv\_ip](#output\_ec2\_instance\_priv\_ip) | n/a |
| <a name="output_ec2_instance_pub_ip"></a> [ec2\_instance\_pub\_ip](#output\_ec2\_instance\_pub\_ip) | n/a |
| <a name="output_ec2_instance_security_groups"></a> [ec2\_instance\_security\_groups](#output\_ec2\_instance\_security\_groups) | n/a |
| <a name="output_ec2_instance_subnet_id"></a> [ec2\_instance\_subnet\_id](#output\_ec2\_instance\_subnet\_id) | n/a |
<!-- END_TF_DOCS -->