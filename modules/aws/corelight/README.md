# Corelight Collector
Utilized to deploy a corelight collector

# Interfaces
- eth0 - Collecto listener. Send VPC Mirror traffic to this interface
- eth1 - Management

# Usage
    module "aws_prod_corelight" {
      source              = "github.com/thinkstack-co/terraform-modules//modules/aws/corelight"
      
      ami                 = "ami-b7f895cffdsaaafdsa"
      availability_zones  = [module.vpc.availability_zone[0], module.vpc.availability_zone[1]]
      number              = 2
      listener_subnet_ids = module.vpc.private_subnet_ids
      mgmt_subnet_ids     = module.vpc.mgmt_subnet_ids
      name                = "aws_prod_corelight"
      region              = var.aws_region
      user_data           = "customer_id_key"
      vpc_id              = "vpc-222222222"
      vxlan_cidr_blocks   = ["10.44.1.1/32"]
      
      tags                = {
        terraform        = "true"
        created_by       = "Zachary Hill"
        environment      = "prod"
        role             = "corelight network monitor"
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
| [aws_cloudwatch_metric_alarm.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_instance.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_lb.corelight_nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_network_interface.listener_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.mgmt_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_security_group.corelight_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | (Required) AMI ID to use when launching the instance | `string` | n/a | yes |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | (Required) The AZ to start the instance in | `list(string)` | n/a | yes |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | (Optional) If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | (Optional) If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | (Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `bool` | `false` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | (Optional) Enable volume encryption. (Default: false). Must be configured to perform drift detection. | `bool` | `true` | no |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint) | (Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled. | `string` | `"enabled"` | no |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens) | (Optional) Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Valid values include optional or required. Defaults to optional. | `string` | `"required"` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | (Optional) The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. | `string` | `""` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | (Optional) Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances. See Shutdown Behavior for more information. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior | `string` | `"stop"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | (Optional) The AWS instance type  to utilize for the specifications of the instance | `string` | `"m5.xlarge"` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | (Optional) If true, the LB will be internal. | `bool` | `true` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | (Optional) The key name to use for the instance | `string` | `""` | no |
| <a name="input_listener_nic_description"></a> [listener\_nic\_description](#input\_listener\_nic\_description) | (Optional) A description for the network interface. | `string` | `"Corelight listener nic"` | no |
| <a name="input_listener_subnet_ids"></a> [listener\_subnet\_ids](#input\_listener\_subnet\_ids) | (Required) The VPC Subnet ID to launch in | `list` | n/a | yes |
| <a name="input_mgmt_cidr_blocks"></a> [mgmt\_cidr\_blocks](#input\_mgmt\_cidr\_blocks) | (Optional) List of IP addresses and cidr blocks which are allowed to access SSH and HTTPS to this instance | `list` | `[]` | no |
| <a name="input_mgmt_nic_description"></a> [mgmt\_nic\_description](#input\_mgmt\_nic\_description) | (Optional) A description for the network interface. | `string` | `"Corelight mgmt nic"` | no |
| <a name="input_mgmt_subnet_ids"></a> [mgmt\_subnet\_ids](#input\_mgmt\_subnet\_ids) | (Required) The VPC Subnet ID for the mgmt nic | `list` | n/a | yes |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | (Optional) If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional) Name to be used on all resources as a prefix for tags and names | `string` | `"aws_prod_corelight"` | no |
| <a name="input_nlb_name"></a> [nlb\_name](#input\_nlb\_name) | (Optional) The name of the LB. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen. If not specified, Terraform will autogenerate a name beginning with tf-lb. | `string` | `"aws-prod-corelight-nlb"` | no |
| <a name="input_number"></a> [number](#input\_number) | (Optional) Number of instances and resources to launch | `number` | `1` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | (Optional) The Placement Group to start the instance in | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | (Required) VPC Region the resources exist in | `string` | n/a | yes |
| <a name="input_root_delete_on_termination"></a> [root\_delete\_on\_termination](#input\_root\_delete\_on\_termination) | (Optional) Whether the volume should be destroyed on instance termination (Default: true) | `string` | `true` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | (Optional) The size of the volume in gigabytes. | `string` | `"64"` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | (Optional) The type of volume. Can be standard, gp2, or io1. (Default: standard) | `string` | `"gp2"` | no |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | (Optional, Forces new resource) The security group description. Defaults to 'Managed by Terraform'. Cannot be ''. NOTE: This field maps to the AWS GroupDescription attribute, for which there is no Update API. If you'd like to classify your security groups in a way that can be updated, use tags. | `string` | `"Corelight security group"` | no |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | (Optional, Forces new resource) The name of the security group. If omitted, Terraform will assign a random, unique name | `string` | `"corelight_sg"` | no |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | (Optional) Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map` | <pre>{<br>  "backup": "true",<br>  "created_by": "terraform",<br>  "environment": "prod",<br>  "role": "corelight network monitor",<br>  "terraform": "true"<br>}</pre> | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | (Optional) The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host. | `string` | `"default"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | (Required) Input the Customer ID from Corelight. Example: '57ee000-1214-999e-hfij-1827417d7421' | `any` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required, Forces new resource) The VPC ID. | `string` | n/a | yes |
| <a name="input_vxlan_cidr_blocks"></a> [vxlan\_cidr\_blocks](#input\_vxlan\_cidr\_blocks) | (Required) List of IP addresses and cidr blocks which are allowed to send VPC mirror traffic | `list` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone) | List of availability zones of instances |
| <a name="output_id"></a> [id](#output\_id) | List of IDs of instances |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | List of private IP addresses assigned to the instances |
<!-- END_TF_DOCS -->