# AWS Network Diagram Generator Terraform Module

This module deploys a scheduled Lambda function that scans your AWS account and generates comprehensive network architecture diagrams. The diagrams are automatically uploaded to S3 with organized date-based folder structure.

## Features

### Resources Discovered and Visualized
- **VPCs**: Shows VPC CIDR blocks and names
- **Availability Zones**: Groups resources by AZ for clear visualization
- **Subnets**: Differentiates between public and private subnets with CIDR blocks
- **EC2 Instances**: Shows instance names, types, and running state
- **Load Balancers**: Supports ALB, NLB, and Classic ELB
- **Target Groups**: Shows target group associations and health status
- **AWS WAF**: Displays Web ACLs and their associations with load balancers
- **S3 Buckets**: Shows regional S3 buckets (limited to 10 for readability)

### Diagram Features
- **Hierarchical Organization**: Resources are organized by VPC → AZ → Subnet type
- **Visual Connections**: Shows relationships between WAF → Load Balancers → Target Groups → EC2 instances
- **Health Status**: Target group health checks are color-coded (green for healthy, red for unhealthy)
- **Color Coding**: Different resource types use distinct colors for easy identification
- **Date-based Storage**: Diagrams are stored with timestamp and organized by year/month/day
- **Latest Version**: Always maintains a "latest" version for easy access

## Usage Example

```hcl
module "network_diagram_generator" {
  source = "./modules/aws/network_diagram_generator"
  
  name             = "my-network-diagrams"
  s3_bucket_prefix = "my-network-diagrams"  # A unique suffix will be appended automatically
  schedule         = "cron(0 2 ? * SUN *)"  # Weekly on Sunday at 2 AM
  
  tags = {
    Environment = "production"
    Team        = "infrastructure"
  }
}
```

## Inputs

| Name             | Description                                                      | Type   | Default                    |
|------------------|------------------------------------------------------------------|--------|----------------------------|
| name             | Base name for resources                                          | string | network-diagram-generator  |
| s3_bucket_prefix | Prefix for the S3 bucket name to store diagrams                  | string | network-diagrams           |
| schedule         | EventBridge cron schedule for Lambda execution                   | string | cron(0 2 ? * SUN *)        |
| tags             | Tags to apply to all resources                                   | map    | {}                         |

## Outputs

| Name                    | Description                                      |
|-------------------------|--------------------------------------------------|
| lambda_function_arn     | ARN of the Lambda function                       |
| lambda_function_name    | Name of the Lambda function                      |
| diagram_s3_bucket       | S3 bucket where diagrams are stored              |
| event_rule_arn          | ARN of the EventBridge rule                      |
| event_rule_name         | Name of the EventBridge rule                     |
| log_group_name          | CloudWatch log group name for the Lambda         |
| latest_diagram_s3_key   | S3 key for the latest network diagram            |

## S3 Storage Structure

Diagrams are stored in S3 with the following structure:
```
s3://bucket-name/
├── network-diagrams/
│   ├── 2024/
│   │   ├── 01/
│   │   │   ├── 15/
│   │   │   │   └── network_diagram_2024-01-15_14-30-00.png
│   │   │   └── 22/
│   │   │       └── network_diagram_2024-01-22_14-30-00.png
│   │   └── 02/
│   │       └── ...
│   └── latest/
│       └── network_diagram.png  # Always contains the most recent diagram
```

## Lambda Function Details

- **Runtime**: Python 3.11
- **Memory**: 1024 MB
- **Timeout**: 15 minutes
- **Dependencies**: boto3, diagrams library
- **Log Retention**: 14 days

## IAM Permissions

The Lambda function has read-only access to:
- EC2 (VPCs, Subnets, Instances, Availability Zones, Tags)
- Elastic Load Balancing (Load Balancers, Target Groups, Listeners, Health)
- WAF/WAFv2 (Web ACLs, Associations)
- S3 (List buckets, Get bucket locations)

Write access is limited to the specified S3 bucket for diagram storage.

## Manual Execution

To manually trigger diagram generation:

```bash
# Using AWS CLI
aws lambda invoke \
  --function-name my-network-diagrams-network-diagram \
  --region us-east-1 \
  output.json

# Check the result
cat output.json
```

## Viewing Diagrams

After generation, you can access your diagrams:

```bash
# Download the latest diagram
aws s3 cp s3://your-bucket/network-diagrams/latest/network_diagram.png ./

# List all historical diagrams
aws s3 ls s3://your-bucket/network-diagrams/ --recursive

# Generate a presigned URL for sharing (valid for 1 hour)
aws s3 presign s3://your-bucket/network-diagrams/latest/network_diagram.png --expires-in 3600
```

## Notes

- The Lambda function requires the Python `diagrams` library which has native dependencies. The module expects these to be included in the lambda/ directory.
- For large AWS environments, consider increasing the Lambda memory allocation or timeout values.
- S3 buckets are limited to the same region as the Lambda function for performance.
- The diagram shows only running EC2 instances to reduce clutter.
- Target group health status requires active health checks to be configured.

## Building the Lambda Package

Due to the `diagrams` library's dependencies on Graphviz, you may need to build the Lambda package in a compatible environment:

```bash
# Using Docker with Amazon Linux
docker run -v "$PWD":/var/task "public.ecr.aws/sam/build-python3.11" /bin/sh -c "pip install diagrams boto3 -t /var/task/lambda/; cp /usr/bin/dot /var/task/lambda/"
```

## Troubleshooting

1. **Empty Diagrams**: Check CloudWatch logs for permission errors
2. **Missing Resources**: Ensure the Lambda has appropriate IAM permissions
3. **Generation Failures**: Increase Lambda memory/timeout for large environments
4. **S3 Upload Errors**: Verify S3 bucket exists and Lambda has write permissions
