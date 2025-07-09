# Weekly Backup Vault Example

This example demonstrates how to set up a weekly backup vault using the AWS Backup Custom module with AWS-managed encryption keys.

## Features

- Creates a weekly backup vault in the primary region
- Optionally creates a DR vault in a secondary region
- Uses AWS-managed KMS keys (aws/backup) for encryption
- Implements tag-based resource selection
- Demonstrates backing up multiple resource types (EC2, EBS, EFS)
- Includes vault lock option for compliance

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Configuration

### Basic Weekly Backup

```hcl
module "example" {
  source = "../weekly_vault"
  
  aws_region   = "us-east-1"
  project_name = "my-weekly-backups"
  
  tags = {
    environment = "production"
  }
}
```

### Weekly Backup with DR

```hcl
module "example" {
  source = "../weekly_vault"
  
  aws_region   = "us-east-1"
  dr_region    = "us-west-2"
  project_name = "my-weekly-backups"
  
  enable_dr = true  # Enable DR vault and cross-region copies
  
  tags = {
    environment = "production"
  }
}
```

### Weekly Backup with Vault Lock

```hcl
module "example" {
  source = "../weekly_vault"
  
  aws_region   = "us-east-1"
  project_name = "my-weekly-backups"
  
  enable_vault_lock = true  # Enable vault lock for compliance
  
  tags = {
    environment = "production"
    compliance  = "required"
  }
}
```

## Resource Tagging

To include resources in the weekly backup plan, tag them with:

```hcl
tags = {
  WeeklyBackup = "true"
}
```

## Example Resources

This example can optionally create demo resources:

```hcl
create_example_resources = true
```

This will create:
- An EC2 instance tagged for weekly backups
- An EBS volume tagged for weekly backups
- An EFS file system tagged for weekly backups

## Backup Schedule

- **Schedule**: 2 AM every Sunday
- **Retention**: 35 days (5 weeks)
- **Cold Storage**: Not configured for weekly backups
- **DR Retention**: 14 days (2 weeks) if DR is enabled

## Supported Resource Types

This example demonstrates backing up:
- EC2 instances
- EBS volumes
- EFS file systems
- RDS databases (can be added)
- DynamoDB tables (can be added)
- S3 buckets (can be added)

## Requirements

- Terraform >= 1.0.0
- AWS Provider >= 4.0.0

## Outputs

- `backup_vault_name` - Name of the weekly backup vault
- `backup_vault_arn` - ARN of the weekly backup vault
- `dr_vault_name` - Name of the DR vault (if enabled)
- `dr_vault_arn` - ARN of the DR vault (if enabled)
- `backup_plan_id` - ID of the backup plan
- `backup_plan_arn` - ARN of the backup plan
- `backup_selection_id` - ID of the backup selection
- `iam_role_arn` - ARN of the IAM role used for backups
- `example_resources` - IDs of example resources (if created)