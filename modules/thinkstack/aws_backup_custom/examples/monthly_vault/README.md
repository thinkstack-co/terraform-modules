# Monthly Backup Vault Example

This example demonstrates how to set up a monthly backup vault using the AWS Backup Custom module with AWS-managed encryption keys.

## Features

- Creates a monthly backup vault in the primary region
- Optionally creates a DR vault in a secondary region
- Uses AWS-managed KMS keys (aws/backup) for encryption
- Implements tag-based resource selection
- Includes lifecycle policies for cold storage transition
- Demonstrates vault lock for compliance requirements

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Configuration

### Basic Monthly Backup

```hcl
module "example" {
  source = "../monthly_vault"
  
  aws_region   = "us-east-1"
  project_name = "my-monthly-backups"
  
  tags = {
    environment = "production"
    compliance  = "required"
  }
}
```

### Monthly Backup with DR

```hcl
module "example" {
  source = "../monthly_vault"
  
  aws_region   = "us-east-1"
  dr_region    = "us-west-2"
  project_name = "my-monthly-backups"
  
  enable_dr = true  # Enable DR vault and cross-region copies
  
  tags = {
    environment = "production"
    compliance  = "required"
  }
}
```

### Monthly Backup with Vault Lock

```hcl
module "example" {
  source = "../monthly_vault"
  
  aws_region   = "us-east-1"
  project_name = "my-monthly-backups"
  
  enable_vault_lock = true  # Enable vault lock for compliance
  
  tags = {
    environment = "production"
    compliance  = "sox"
  }
}
```

## Resource Tagging

To include resources in the monthly backup plan, tag them with:

```hcl
tags = {
  MonthlyBackup = "true"
}
```

## Example Resources

This example can optionally create demo resources:

```hcl
create_example_resources = true
```

This will create:
- An EC2 instance tagged for monthly backups
- An RDS database instance tagged for monthly backups

## Backup Schedule

- **Schedule**: 3 AM on the 1st of each month
- **Retention**: 365 days (1 year)
- **Cold Storage**: After 90 days
- **DR Retention**: 180 days (6 months) if DR is enabled

## Requirements

- Terraform >= 1.0.0
- AWS Provider >= 4.0.0

## Outputs

- `backup_vault_name` - Name of the monthly backup vault
- `backup_vault_arn` - ARN of the monthly backup vault
- `dr_vault_name` - Name of the DR vault (if enabled)
- `dr_vault_arn` - ARN of the DR vault (if enabled)
- `backup_plan_id` - ID of the backup plan
- `backup_plan_arn` - ARN of the backup plan
- `backup_selection_id` - ID of the backup selection
- `iam_role_arn` - ARN of the IAM role used for backups
- `example_resources` - IDs of example resources (if created)