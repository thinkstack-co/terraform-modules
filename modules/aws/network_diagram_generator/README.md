# AWS Network Diagram Generator Terraform Module

This module deploys a scheduled Lambda function that scans your AWS account, generates a network/resource diagram (VPCs, subnets, EC2, security groups), and uploads it to S3. The Lambda runs weekly by default.

## Features

- Discovers VPCs, subnets, EC2 instances, and security groups
- Generates a PNG diagram using the [diagrams](https://diagrams.mingrammer.com/) Python library
- Stores the diagram in an S3 bucket
- Runs on a schedule (weekly by default)

## Usage Example

```hcl
module "network_diagram_generator" {
  source = "./modules/aws/network_diagram_generator"
  name   = "my-diagram-generator"
  # s3_bucket_name = "my-existing-bucket" # Optional
  # schedule = "cron(0 2 ? * SUN *)"      # Optional
}
```

## Inputs

| Name           | Description                                 | Type   | Default     |
|----------------|---------------------------------------------|--------|-------------|
| name           | Base name for resources                     | string | network-diagram-generator |
| s3_bucket_name | S3 bucket to store diagrams (optional)      | string | null        |
| schedule       | EventBridge cron schedule for Lambda        | string | `cron(0 2 ? * SUN *)` |

## Outputs

| Name                | Description                      |
|---------------------|----------------------------------|
| lambda_function_arn | ARN of the Lambda function       |
| diagram_s3_bucket   | S3 bucket where diagrams are stored |
| event_rule_arn      | ARN of the EventBridge rule      |

## Lambda Function

- Python 3.11
- Uses `boto3` and `diagrams` libraries
- Uploads PNG diagram to S3 as `network_diagram.png`

## Notes

- The Lambda function is a basic example. Extend it to include more AWS resources, relationships, and improved visualizations as needed.
- Ensure the Lambda deployment package includes all dependencies (`boto3`, `diagrams`, `graphviz`).
- You may need to build the Lambda package in a compatible environment (e.g., Docker with Amazon Linux) due to native dependencies.
