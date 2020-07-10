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
| key\_name\_prefix | SSL key pair name prefix, used to generate unique keypair name for EC2 instance deployments | `any` | n/a | yes |
| public\_key | Public rsa key | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| key\_name | n/a |