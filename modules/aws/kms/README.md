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
| deletion\_window\_in\_days | (Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days. | `number` | `30` | no |
| description | (Optional) The description of the key as viewed in AWS console. | `string` | `""` | no |
| enable\_key\_rotation | (Optional) Specifies whether key rotation is enabled. Defaults to false. | `bool` | `true` | no |
| is\_enabled | (Optional) Specifies whether the key is enabled. Defaults to true. | `string` | `true` | no |
| key\_usage | (Optional) Specifies the intended use of the key. Defaults to ENCRYPT\_DECRYPT, and only symmetric encryption and decryption are supported. | `string` | `"ENCRYPT_DECRYPT"` | no |
| name | (Optional) The display name of the alias. The name must start with the word 'alias' followed by a forward slash | `string` | n/a | yes |
| policy | (Optional) A valid policy JSON document. | `string` | `""` | no |
| tags | (Optional) A mapping of tags to assign to the object. | `map` | <pre>{<br>  "created_by": "terraform",<br>  "terraform": "true"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| kms\_key\_arn | n/a |
| kms\_key\_id | n/a |