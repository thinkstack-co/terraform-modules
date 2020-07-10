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
| count | Number of instances to launch | `number` | `1` | no |
| ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| instance\_name\_prefix | Used to populate the Name tag. Set in main.tf | `any` | n/a | yes |
| instance\_type | Select the instance type. Set in main.tf | `string` | `"t2.medium"` | no |
| key\_name | keypair name to use for ec2 instance deployment. Keypairs are used to obtain the username/password | `any` | n/a | yes |
| private\_ip | Private IP address to associate with the instance in a VPC | `string` | `""` | no |
| region | (Required) VPC Region the resources exist in | `string` | n/a | yes |
| security\_group\_ids | Lits of security group ids to attach to the instance | `list` | n/a | yes |
| subnet\_id | The VPC subnet the instance(s) will be assigned. Set in main.tf | `any` | n/a | yes |
| tags | n/a | `map` | <pre>{<br>  "created_by": "terraform",<br>  "terraform": "true"<br>}</pre> | no |
| user\_data | The path to a file with user\_data for the instances | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| ec2\_instance\_id | n/a |
| ec2\_instance\_network\_id | n/a |
| ec2\_instance\_priv\_ip | n/a |
| ec2\_instance\_pub\_ip | n/a |
| ec2\_instance\_security\_groups | n/a |
| ec2\_instance\_subnet\_id | n/a |
