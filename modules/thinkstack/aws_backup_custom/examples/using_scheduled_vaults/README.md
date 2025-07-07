# AWS Backup with Scheduled Vaults Example

This example demonstrates how to use the enhanced `aws_backup_vault` module with automatic scheduled vault creation and DR support.

## Features Demonstrated

1. **Automatic Vault Creation** - Creates vaults for different backup schedules
2. **DR Support** - Automatically creates corresponding DR vaults in another region
3. **Flexible Configuration** - Enable only the schedules you need
4. **Cross-Region Copies** - Backup plans include copy actions to DR vaults
5. **Tag-Based Selection** - Resources are selected for backup based on tags

## Usage

### Basic Usage (Daily, Weekly, Monthly)
```bash
terraform init
terraform plan
terraform apply
```

### With DR Enabled
```bash
terraform init
terraform plan -var="enable_dr=true"
terraform apply -var="enable_dr=true"
```

### With All Schedules
```bash
terraform init
terraform plan \
  -var="enable_hourly_vault=true" \
  -var="enable_yearly_vault=true" \
  -var="enable_dr=true"
terraform apply \
  -var="enable_hourly_vault=true" \
  -var="enable_yearly_vault=true" \
  -var="enable_dr=true"
```

### With Selective DR
```bash
# Enable DR but only for daily and weekly vaults
terraform init
terraform plan \
  -var="enable_dr=true" \
  -var="enable_hourly_dr=false" \
  -var="enable_monthly_dr=false" \
  -var="enable_yearly_dr=false"
terraform apply \
  -var="enable_dr=true" \
  -var="enable_hourly_dr=false" \
  -var="enable_monthly_dr=false" \
  -var="enable_yearly_dr=false"
```

## Tagging Strategy

Resources should be tagged with the appropriate backup schedule:

```hcl
resource "aws_instance" "example" {
  # ... instance configuration ...
  
  tags = {
    backup_schedule = "daily"    # Options: hourly, daily, weekly, monthly, yearly
    Environment     = "production"
    Critical        = "true"     # For critical resource selection example
  }
}
```

## Variables

| Name | Default | Description |
|------|---------|-------------|
| `enable_hourly_vault` | `false` | Create hourly backup vault and plan |
| `enable_daily_vault` | `true` | Create daily backup vault and plan |
| `enable_weekly_vault` | `true` | Create weekly backup vault and plan |
| `enable_monthly_vault` | `true` | Create monthly backup vault and plan |
| `enable_yearly_vault` | `false` | Create yearly backup vault and plan |
| `enable_dr` | `false` | Enable DR vaults and cross-region copies |
| `enable_vault_lock` | `false` | Enable vault lock on all vaults |
| `dr_region` | `us-west-2` | DR region for backup copies |
| `enable_hourly_dr` | `true` | Create DR vault for hourly backups |
| `enable_daily_dr` | `true` | Create DR vault for daily backups |
| `enable_weekly_dr` | `true` | Create DR vault for weekly backups |
| `enable_monthly_dr` | `true` | Create DR vault for monthly backups |
| `enable_yearly_dr` | `true` | Create DR vault for yearly backups |

## Vault Structure

When all options are enabled, the following vaults are created:

### Primary Region
- `{project_name}-hourly`
- `{project_name}-daily`
- `{project_name}-weekly`
- `{project_name}-monthly`
- `{project_name}-yearly`

### DR Region (when enabled)
- `{project_name}-dr-hourly`
- `{project_name}-dr-daily`
- `{project_name}-dr-weekly`
- `{project_name}-dr-monthly`
- `{project_name}-dr-yearly`

## Retention Periods

| Schedule | Primary Retention | DR Retention |
|----------|------------------|--------------|
| Hourly | 1 day | 3 days |
| Daily | 7 days | 14 days |
| Weekly | 30 days | 60 days |
| Monthly | 365 days | 730 days (2 years) |
| Yearly | 2555 days (7 years) | 2555 days (7 years) |

## Requirements

- Terraform >= 1.0.0
- AWS Provider >= 4.0.0

## Outputs

See `outputs.tf` for available outputs including vault ARNs, plan IDs, and KMS key IDs.