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
| description | (Optional) Description of what your Lambda Function does. | `any` | n/a | yes |
| filename | (Optional) The path to the function's deployment package within the local filesystem. If defined, The s3\_-prefixed options cannot be used. | `any` | n/a | yes |
| function\_name | (Required) A unique name for your Lambda Function. | `any` | n/a | yes |
| handler | (Required) The function entrypoint in your code. | `string` | `"main.handler"` | no |
| memory\_size | (Optional) Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128. See Limits | `string` | `128` | no |
| role | (Required) IAM role attached to the Lambda Function. This governs both who or what can invoke your Lambda Function, as well as what resources our Lambda Function has access to. See Lambda Permission Model for more details. | `any` | n/a | yes |
| runtime | (Required) See Runtimes for valid values. | `string` | `"python3.6"` | no |
| source\_code\_hash | (Optional) Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file specified with either filename or s3\_key | `any` | n/a | yes |
| timeout | (Optional) The amount of time your Lambda Function has to run in seconds. Defaults to 3. See Limits | `number` | `180` | no |
| variables | (Optional) A map that defines environment variables for the Lambda function. | `map` | <pre>{<br>  "lambda": "true"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | n/a |