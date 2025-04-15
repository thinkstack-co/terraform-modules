# AWS Config Compliance Reporter Lambda Function

This Lambda function generates PDF compliance reports based on AWS Config rule evaluations. It summarizes the compliance status of all Config rules in the account and provides details about non-compliant resources.

## Features

- Generates comprehensive PDF compliance reports
- Includes account name and ID in the report header
- Lists all AWS Config rules and their compliance status
- Details non-compliant resources with resource types and names
- Uploads reports to an S3 bucket for easy access

## Dependencies

This Lambda function uses the following dependencies:
- `reportlab`: For PDF generation (provided via Lambda Layer)
- `boto3`: For AWS API interactions (included in Lambda runtime)

## Configuration

The Lambda function requires the following environment variables:
- `S3_BUCKET_NAME`: The S3 bucket where reports will be stored
- `REPORT_S3_PREFIX`: (Optional) The prefix within the bucket for storing reports (default: 'compliance-reports/')

## Deployment

This Lambda function is designed to be deployed as part of the AWS Config module. The module uses a Lambda Layer approach for dependencies, which ensures compatibility across all AWS environments.

## IAM Permissions

The Lambda function requires the following permissions:
- AWS Config read access
- S3 write access to the Config bucket
- STS access for account ID
- Organizations access for account name
- IAM access for account aliases
- EC2, RDS, and S3 tag access for resource names

## Usage

The Lambda function can be triggered on a schedule (using EventBridge) or manually.
