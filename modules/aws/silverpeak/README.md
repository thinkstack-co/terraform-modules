
# Interfaces
 - wan0 - Typically behind a firewall NATing the public IP address to a DMZ IP address
 - lan0 - Typically on the private/server subnet
 - mgmt0 - Typically set in a mgmt subnet

# Usage
    module "aws_prod_silverpeak" {
      source            = "github.com/thinkstack-co/terraform-modules//modules/aws/silverpeak"
      
      ami               = "ami-b7f895cf"
      availability_zone = module.vpc.availability_zone[0]
      count             = 1
      dmz_subnet_id     = module.vpc.dmz_subnet_ids
      ebs_optimized     = true
      instance_type     = "c4.large"
      key_name          = module.keypair.key_name
      monitoring        = true
      lan0_private_ips  = ["10.11.1.20"]
      mgmt0_private_ips = ["10.11.21.20"]
      mgmt_subnet_id    = module.vpc.mgmt_subnet_ids
      name              = "aws_prod_silverpeak"
      private_subnet_id = module.vpc.private_subnet_ids
      root_volume_type  = "gp2"
      root_volume_size  = "100"
      
      tags              = {
        terraform        = "yes"
        created_by       = "Zachary Hill"
        environment      = "prod"
        role             = "silverpeak_sdwan"
        backup           = "true"
        hourly_retention = "7"
      }
      wan0_private_ips  = ["10.11.101.20"]
      vpc_id            = module.vpc.vpc_id
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
| [aws_instance.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_network_interface.lan0_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.mgmt0_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.wan0_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_security_group.silverpeak_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | ID of AMI to use for the instance | `any` | n/a | yes |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The AZ to start the instance in | `string` | `""` | no |
| <a name="input_count"></a> [count](#input\_count) | The total number of resources to create | `number` | `1` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| <a name="input_dmz_subnet_id"></a> [dmz\_subnet\_id](#input\_dmz\_subnet\_id) | (Required) Subnet ID to create the ENI in. | `list` | n/a | yes |
| <a name="input_ebs_block_device"></a> [ebs\_block\_device](#input\_ebs\_block\_device) | Additional EBS block devices to attach to the instance | `list` | `[]` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| <a name="input_ephemeral_block_device"></a> [ephemeral\_block\_device](#input\_ephemeral\_block\_device) | Customize Ephemeral (also known as Instance Store) volumes on the instance | `list` | `[]` | no |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint) | (Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled. | `string` | `"enabled"` | no |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens) | (Optional) Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Valid values include optional or required. Defaults to optional. | `string` | `"required"` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. | `string` | `""` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | (Optional) Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances. See Shutdown Behavior for more information. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior | `string` | `"stop"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of instance to start | `string` | `"c4.large"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The key name to use for the instance | `string` | `""` | no |
| <a name="input_lan0_description"></a> [lan0\_description](#input\_lan0\_description) | (Optional) A description for the network interface. | `string` | `"Silverpeak lan0 nic"` | no |
| <a name="input_lan0_private_ips"></a> [lan0\_private\_ips](#input\_lan0\_private\_ips) | (Optional) List of private IPs to assign to the ENI. | `list` | n/a | yes |
| <a name="input_mgmt0_description"></a> [mgmt0\_description](#input\_mgmt0\_description) | (Optional) A description for the network interface. | `string` | `"Silverpeak mgmt0 nic"` | no |
| <a name="input_mgmt0_private_ips"></a> [mgmt0\_private\_ips](#input\_mgmt0\_private\_ips) | (Optional) List of private IPs to assign to the ENI. | `list` | n/a | yes |
| <a name="input_mgmt_subnet_id"></a> [mgmt\_subnet\_id](#input\_mgmt\_subnet\_id) | (Required) Subnet ID to create the ENI in. | `list` | n/a | yes |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all resources as prefix | `any` | n/a | yes |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | The Placement Group to start the instance in | `string` | `""` | no |
| <a name="input_private_subnet_id"></a> [private\_subnet\_id](#input\_private\_subnet\_id) | (Required) Subnet ID to create the ENI in. | `list` | n/a | yes |
| <a name="input_root_delete_on_termination"></a> [root\_delete\_on\_termination](#input\_root\_delete\_on\_termination) | (Optional) Whether the volume should be destroyed on instance termination (Default: true) | `string` | `true` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | (Optional) The size of the volume in gigabytes. | `string` | `"100"` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | (Optional) The type of volume. Can be standard, gp2, or io1. (Default: standard) | `string` | `"gp2"` | no |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | (Optional, Forces new resource) The security group description. Defaults to 'Managed by Terraform'. Cannot be ''. NOTE: This field maps to the AWS GroupDescription attribute, for which there is no Update API. If you'd like to classify your security groups in a way that can be updated, use tags. | `string` | `"Silverpeak SDWAN security group"` | no |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | (Optional, Forces new resource) The name of the security group. If omitted, Terraform will assign a random, unique name | `string` | `"silverpeak_sg"` | no |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | (Optional) Whether to enable source destination checking for the ENI. Default true. | `string` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map` | <pre>{<br>  "backup": "true",<br>  "created_by": "terraform",<br>  "environment": "prod",<br>  "role": "silverpeak_sdwan",<br>  "terraform": "true"<br>}</pre> | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host. | `string` | `"default"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to provide when launching the instance | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Optional, Forces new resource) The VPC ID. | `any` | n/a | yes |
| <a name="input_wan0_description"></a> [wan0\_description](#input\_wan0\_description) | (Optional) A description for the network interface. | `string` | `"Silverpeak wan0 nic"` | no |
| <a name="input_wan0_private_ips"></a> [wan0\_private\_ips](#input\_wan0\_private\_ips) | (Optional) List of private IPs to assign to the ENI. | `list` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->