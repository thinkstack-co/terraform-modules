## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami | The AMI to use | `any` | n/a | yes |
| availability\_zone | The AZ to start the instance in | `string` | `""` | no |
| disable\_api\_termination | If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| domain\_name | Domain name suffix to add to DHCP DNS | `any` | n/a | yes |
| ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| encrypted | (Optional) Enable volume encryption. (Default: false). Must be configured to perform drift detection. | `bool` | `true` | no |
| iam\_instance\_profile | The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. | `string` | `""` | no |
| instance\_initiated\_shutdown\_behavior | Shutdown behavior for the instance | `string` | `""` | no |
| instance\_type | Select the instance type. Set in main.tf | `string` | `"t2.medium"` | no |
| key\_name | keypair name to use for ec2 instance deployment. Keypairs are used to obtain the username/password | `string` | `""` | no |
| monitoring | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `false` | no |
| name | Name of the instance | `any` | n/a | yes |
| number | number of instances to make | `number` | `2` | no |
| placement\_group | The Placement Group to start the instance in | `string` | `""` | no |
| private\_ip | Private IP address to associate with the instance in a VPC | `list` | `[]` | no |
| region | (Required) VPC Region the resources exist in | `string` | n/a | yes |
| root\_delete\_on\_termination | (Optional) Whether the volume should be destroyed on instance termination (Default: true) | `string` | `true` | no |
| root\_iops | (Optional) The amount of provisioned IOPS. This is only valid for volume\_type of io1, and must be specified if using that type | `string` | `""` | no |
| root\_volume\_size | (Optional) The size of the volume in gigabytes. | `string` | `"100"` | no |
| root\_volume\_type | (Optional) The type of volume. Can be standard, gp2, or io1. (Default: standard) | `string` | `"gp2"` | no |
| source\_dest\_check | Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. | `bool` | `true` | no |
| subnet\_id | The VPC subnet the instance(s) will be assigned. Set in main.tf | `list` | `[]` | no |
| tags | A mapping of tags to assign to the resource | `map` | `{}` | no |
| tenancy | The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host. | `string` | `"default"` | no |
| user\_data | The user data to provide when launching the instance | `string` | `""` | no |
| vpc\_id | The VPC id to add the security group | `any` | n/a | yes |
| vpc\_security\_group\_ids | A list of security group IDs to associate with | `list` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dhcp\_options\_id | n/a |
| ec2\_instance\_id | n/a |
| ec2\_instance\_priv\_ip | n/a |
| ec2\_instance\_pub\_ip | n/a |
| ec2\_instance\_security\_groups | n/a |
| ec2\_instance\_subnet\_id | n/a |

