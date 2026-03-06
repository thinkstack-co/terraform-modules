# Module: 08-session-hosts

Deploys Azure Virtual Desktop session host VMs with Trusted Launch, Entra ID join, AVD agent registration, and FSLogix profile configuration.

## Resources Created

- Network interfaces (one per host)
- Windows 11 VMs (Trusted Launch: vTPM + Secure Boot, Windows Client license)
- AADLoginForWindows extension (Entra ID join)
- DSC extension (AVD agent + host pool registration)
- Custom Script Extension (FSLogix registry configuration)

## Important: Registration Token Expiry

The `registration_token` from module 05-avd expires 2 hours after apply. Session hosts must be created within that window. If the token has expired, refresh it first:

```bash
terraform apply -target=module.avd.azurerm_virtual_desktop_host_pool_registration_info.customer
```

Then immediately apply session hosts:

```bash
terraform apply -target=module.session_hosts
```

## Usage

```hcl
module "session_hosts" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/08-session-hosts?ref=v1.0.0"

  resource_group_name     = azurerm_resource_group.avd.name
  location                = var.location
  customer_name           = var.customer_name
  host_count              = var.session_host_count
  subnet_id               = module.mgmt_vnet.subnet_ids["mgmt_avd"]
  gallery_image_id        = module.vm_imaging.image_definition_ids["win11-multisession"]
  host_pool_id            = module.avd.customer_host_pool_id
  registration_token      = module.avd.customer_registration_token
  fslogix_storage_account = module.storage.storage_account_name
  fslogix_storage_key     = module.storage.storage_account_key
  admin_username          = var.vm_admin_username
  admin_password          = var.vm_admin_password
  tags                    = local.common_tags
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `resource_group_name` | string | required | Resource group name |
| `location` | string | required | Azure Government region |
| `customer_name` | string | required | Short customer name |
| `host_count` | number | `5` | Number of VMs to create |
| `vm_size` | string | `Standard_D4s_v5` | VM size |
| `subnet_id` | string | required | NIC subnet resource ID |
| `gallery_image_id` | string | required | Gallery image definition resource ID |
| `image_version` | string | `latest` | Gallery image version |
| `host_pool_id` | string | required | AVD host pool resource ID |
| `registration_token` | string | required | AVD registration token (sensitive) |
| `fslogix_storage_account` | string | required | FSLogix storage account name |
| `fslogix_storage_key` | string | required | FSLogix storage key (sensitive) |
| `fslogix_share_name` | string | `fslogixprofiles` | FSLogix share name |
| `admin_username` | string | `avdadmin` | VM local admin username |
| `admin_password` | string | required | VM local admin password (sensitive) |
| `os_disk_type` | string | `Premium_LRS` | OS disk storage type |
| `tags` | map(string) | `{}` | Resource tags |

## Outputs

| Name | Description |
|---|---|
| `vm_ids` | List of VM resource IDs |
| `vm_names` | List of VM names |
| `private_ips` | List of private IP addresses |
