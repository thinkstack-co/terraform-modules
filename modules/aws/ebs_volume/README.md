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
| availability\_zone | The AZ where the EBS volume will exist | `any` | n/a | yes |
| device\_name | The device name to expose to the instance (for example, /dev/sdh or xvdf) | `string` | `"xvdf"` | no |
| encrypted | Whether or not the ebs volume will be encrypted | `bool` | `true` | no |
| instance\_id | ID of the instance to attach to | `string` | n/a | yes |
| iops | iops to provision | `string` | `""` | no |
| size | size of the ebs volume | `string` | n/a | yes |
| snapshot\_id | snapshot id to base the volume from | `string` | `""` | no |
| tags | tags to assign to the ebs volume | `map` | `{}` | no |
| type | ebs volume type (example gp2, io1, standard, sc1, st1) | `string` | `"gp2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | n/a |