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
| ami | ID of AMI to use for the instance | `any` | n/a | yes |
| associate\_public\_ip\_address | If true, the EC2 instance will have associated public IP address | `bool` | `false` | no |
| attachment | Attachment block for assigning the eni to an instance | `list` | `[]` | no |
| availability\_zone | The AZ to start the instance in | `string` | `""` | no |
| delete\_on\_termination | whether or not to delete the eni on instance termination | `bool` | `false` | no |
| description | (Optional) A description for the network interface | `string` | n/a | yes |
| device\_index | eni index to attach the eni to on the instance | `any` | n/a | yes |
| disable\_api\_termination | If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| ebs\_block\_device | Additional EBS block devices to attach to the instance | `list` | `[]` | no |
| ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| eni\_number | Number of instances to launch | `number` | `1` | no |
| ephemeral\_block\_device | Customize Ephemeral (also known as Instance Store) volumes on the instance | `list` | `[]` | no |
| iam\_instance\_profile | The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. | `string` | `""` | no |
| instance\_initiated\_shutdown\_behavior | Shutdown behavior for the instance | `string` | `""` | no |
| instance\_type | The type of instance to start | `any` | n/a | yes |
| ipv6\_address\_count | A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet. | `number` | `0` | no |
| ipv6\_addresses | Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface | `list` | `[]` | no |
| key\_name | The key name to use for the instance | `string` | `""` | no |
| monitoring | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `false` | no |
| name | Name to be used on all resources as prefix | `any` | n/a | yes |
| network\_interface | Customize network interfaces to be attached at instance boot time | `list` | `[]` | no |
| number | Number of instances to launch | `number` | `1` | no |
| placement\_group | The Placement Group to start the instance in | `string` | `""` | no |
| private\_ips | (Optional) List of private IPs to assign to the ENI. | `list` | n/a | yes |
| private\_ips\_count | Number of private IPs to assign to the eni | `number` | `0` | no |
| region | (Required) VPC Region the resources exist in | `string` | n/a | yes |
| root\_block\_device | Customize details about the root block device of the instance. See Block Devices below for details | `list` | `[]` | no |
| source\_dest\_check | Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. | `bool` | `true` | no |
| subnet\_id | (Required) Subnet ID to create the ENI and EC2 instance in. | `string` | `""` | no |
| tags | A mapping of tags to assign to the resource | `map` | `{}` | no |
| tenancy | The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host. | `string` | `"default"` | no |
| user\_data | The user data to provide when launching the instance | `string` | `""` | no |
| vpc\_security\_group\_ids | A list of security group IDs to associate with | `list` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| availability\_zone | List of availability zones of instances |
| id | List of IDs of instances |
| key\_name | List of key names of instances |
| network\_interface\_id | List of IDs of the network interface of instances |
| primary\_network\_interface\_id | List of IDs of the primary network interface of instances |
| private\_dns | List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC |
| private\_ip | List of private IP addresses assigned to the instances |
| public\_dns | List of public DNS names assigned to the instances. For EC2-VPC, ec2 is only available if you've enabled DNS hostnames for your VPC |
| public\_ip | List of public IP addresses assigned to the instances, if applicable |
| security\_groups | List of associated security groups of instances |
| subnet\_id | List of IDs of VPC subnets of instances |
| vpc\_security\_group\_ids | List of associated security groups of instances, if running in non-default VPC |
