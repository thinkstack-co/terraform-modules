# Module: 06-storage

Deploys a Premium Azure Storage account for FSLogix user profile containers with a Recovery Services Vault and daily/weekly/monthly backup policy.

## Resources Created

- Premium FileStorage account (LRS, TLS 1.2, infra encryption, deny-default ACL)
- `fslogixprofiles` SMB file share with 7-day soft delete
- Recovery Services Vault (Standard, LRS)
- Backup policy: daily@22:00 UTC (14d), weekly/Sunday (4w), monthly/first Sunday (6m)
- Backup container and protected file share item

## Usage

```hcl
module "storage" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/cmmc-enclave-template/modules/06-storage?ref=v2.9.2"

  resource_group_name  = azurerm_resource_group.storage.name
  location             = var.location
  customer_name        = var.customer_name
  storage_account_name = var.storage_account_name
  allowed_subnet_ids   = [module.mgmt_vnet.subnet_ids["mgmt_avd"]]
  tags                 = local.common_tags
}
```

## Inputs

| Name                              | Type         | Default  | Description                          |
| --------------------------------- | ------------ | -------- | ------------------------------------ |
| `resource_group_name`             | string       | required | Resource group name                  |
| `location`                        | string       | required | Azure Government region              |
| `customer_name`                   | string       | required | Short customer name                  |
| `storage_account_name`            | string       | required | Globally unique storage account name |
| `allowed_subnet_ids`              | list(string) | required | Subnet IDs for network ACL allow     |
| `fslogix_share_size_gb`           | number       | `512`    | File share quota in GiB              |
| `backup_daily_retention_days`     | number       | `14`     | Daily retention count                |
| `backup_weekly_retention_weeks`   | number       | `4`      | Weekly retention count               |
| `backup_monthly_retention_months` | number       | `6`      | Monthly retention count              |
| `tags`                            | map(string)  | `{}`     | Resource tags                        |

## Outputs

| Name                   | Description                                                                    |
| ---------------------- | ------------------------------------------------------------------------------ |
| `storage_account_id`   | Storage account resource ID                                                    |
| `storage_account_name` | Storage account name                                                           |
| `storage_account_key`  | Primary access key (sensitive)                                                 |
| `fslogix_unc_path`     | UNC path for FSLogix (`\\account.file.core.usgovcloudapi.net\fslogixprofiles`) |
| `recovery_vault_id`    | Recovery Services Vault resource ID                                            |
