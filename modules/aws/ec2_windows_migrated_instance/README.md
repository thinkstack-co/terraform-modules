## Usage
    module "migrated_instance" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_windows_migrated_instance"

        instance_name_prefix = "migrated_app"
        ami_id               = "ami-ffffffff"
        number_of_instances  = 1
        subnet_id            = module.vpc.private_subnet_ids[0]
        instance_type        = "m5.large"
        key_name             = module.keypair.key_name
        security_group_ids   = "sg-ffffffff"

        tags = {
            terraform        = "true"
            created_by       = "terraform"
            environment      = "prod"
            role             = "application_xtender_sql"
            backup           = "true"
            hourly_retention = "7"
        }
    }


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | ID of AMI to use for the instance | `any` | n/a | yes |
| <a name="input_count"></a> [count](#input\_count) | Number of instances to launch | `number` | `1` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint) | (Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled. | `string` | `"enabled"` | no |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens) | (Optional) Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Valid values include optional or required. Defaults to optional. | `string` | `"required"` | no |
| <a name="input_instance_name_prefix"></a> [instance\_name\_prefix](#input\_instance\_name\_prefix) | Used to populate the Name tag. Set in main.tf | `any` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Select the instance type. Set in main.tf | `string` | `"t2.medium"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | keypair name to use for ec2 instance deployment. Keypairs are used to obtain the username/password | `any` | n/a | yes |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP address to associate with the instance in a VPC | `any` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Required) VPC Region the resources exist in | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Lits of security group ids to attach to the instance | `list` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The VPC subnet the instance(s) will be assigned. Set in main.tf | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map` | <pre>{<br>  "created_by": "terraform",<br>  "terraform": "true"<br>}</pre> | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The path to a file with user\_data for the instances | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_instance_id"></a> [ec2\_instance\_id](#output\_ec2\_instance\_id) | n/a |
| <a name="output_ec2_instance_network_id"></a> [ec2\_instance\_network\_id](#output\_ec2\_instance\_network\_id) | n/a |
| <a name="output_ec2_instance_priv_ip"></a> [ec2\_instance\_priv\_ip](#output\_ec2\_instance\_priv\_ip) | n/a |
| <a name="output_ec2_instance_pub_ip"></a> [ec2\_instance\_pub\_ip](#output\_ec2\_instance\_pub\_ip) | n/a |
| <a name="output_ec2_instance_security_groups"></a> [ec2\_instance\_security\_groups](#output\_ec2\_instance\_security\_groups) | n/a |
| <a name="output_ec2_instance_subnet_id"></a> [ec2\_instance\_subnet\_id](#output\_ec2\_instance\_subnet\_id) | n/a |
<!-- END_TF_DOCS -->