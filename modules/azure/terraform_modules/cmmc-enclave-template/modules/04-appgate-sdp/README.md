# Module: 04-appgate-sdp

Deploys Appgate SDP Zero Trust Network Access infrastructure. Key Vault, SSH key generation, and firewall DNAT rules are fully implemented. **Controller and Gateway VMs are stubbed** pending marketplace image availability verification in Azure Government.

> See [`docs/appgate-image.md`](../../docs/appgate-image.md) for image verification and VM implementation steps.

## Resources Created (Implemented)

- RSA 4096-bit SSH key pairs for Controller and Gateway
- Azure Key Vault with soft-delete and purge protection
- Key Vault secrets storing SSH private keys
- Firewall DNAT rules (Controller: 8443/443/22, Gateway: 8444/8022)
- Firewall network rules (NTP outbound)

## Resources Stubbed (TODO)

- Appgate SDP Controller VM (`azurerm_linux_virtual_machine`)
- Appgate SDP Gateway VM (`azurerm_linux_virtual_machine`)
- Public IPs and NICs for Controller and Gateway
- `azurerm_marketplace_agreement` (if marketplace image available)
- Appgate OIDC application registration (`azuread_application`)

## Completing the Module

### Step 1: Verify marketplace image availability

```bash
az cloud set --name AzureUSGovernment
az login
az vm image list --publisher appgate --all --location usgovarizona --output table
```

### Step 2a: If marketplace image is available

1. Accept the marketplace agreement:

   ```hcl
   resource "azurerm_marketplace_agreement" "appgate" {
     publisher = "appgate"
     offer     = "<offer-from-step-1>"
     plan      = "<sku-from-step-1>"
   }
   ```

2. Uncomment the VM resources in `main.tf` and set the correct `source_image_reference` and `plan {}` block.

### Step 2b: If marketplace image is NOT available

1. Obtain the VHD from the Appgate vendor
2. Upload to a storage account in Azure Government
3. Create an `azurerm_image` resource from the VHD URI
4. Reference `azurerm_image.appgate.id` in `source_image_id` (no `plan {}` block needed)

## Post-Deployment Configuration

After VMs are deployed, run the Appgate configuration scripts (from the `azure-resource-manager` repo) in this order:

1. `provision-appgate.sh` — initial installation
2. `seed-controller.sh` — initialize controller
3. `seed-gateway.sh` — initialize gateway
4. `create-oidc-idp.sh` — OIDC identity provider setup
5. `create-client-profile.sh` — client profiles
6. `create-tunnel-policy.sh` — tunnel policies
7. `create-full-tunnel-entitlement.sh` — entitlements
8. `enable-full-tunnel-default-site.sh` — default site routing

## Usage

```hcl
module "appgate_sdp" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/04-appgate-sdp?ref=v1.0.0"

  resource_group_name = azurerm_resource_group.ztna.name
  location            = var.location
  tenant_id           = var.tenant_id
  ztna_subnet_id      = module.mgmt_vnet.subnet_ids["ztna"]
  firewall_policy_id  = module.mgmt_vnet.firewall_policy_id
  firewall_public_ip  = module.mgmt_vnet.firewall_public_ip
  source_admin_ips    = var.admin_source_ips
  tags                = local.common_tags
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `resource_group_name` | string | required | Resource group name |
| `location` | string | `usgovarizona` | Azure Government region |
| `tenant_id` | string | required | Entra ID tenant ID |
| `ztna_subnet_id` | string | required | ZTNA subnet resource ID |
| `firewall_policy_id` | string | required | Firewall policy resource ID |
| `firewall_public_ip` | string | required | Firewall public IP for DNAT |
| `source_admin_ips` | list(string) | required | Admin IPs allowed SSH access |
| `controller_vm_size` | string | `Standard_B2s` | Controller VM size |
| `gateway_vm_size` | string | `Standard_B2s` | Gateway VM size |
| `tags` | map(string) | `{}` | Resource tags |

## Outputs

| Name | Description |
|---|---|
| `key_vault_id` | Key Vault resource ID |
| `key_vault_name` | Key Vault name |
