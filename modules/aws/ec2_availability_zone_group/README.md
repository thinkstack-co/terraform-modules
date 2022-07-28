# Usage
    module "app_server_d_drive" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_availability_zone_group"

        group_name = "us-east-1-bos-1"

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
| [aws_ec2_availability_zone_group.group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_availability_zone_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_group_name"></a> [group\_name](#input\_group\_name) | (Required) Name of the Availability Zone Group. | `string` | n/a | yes |
| <a name="input_opt_in_status"></a> [opt\_in\_status](#input\_opt\_in\_status) | (Optional) Indicates whether to enable or disable Availability Zone Group. Valid values: opted-in or not-opted-in. | `string` | `"opted-in"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->