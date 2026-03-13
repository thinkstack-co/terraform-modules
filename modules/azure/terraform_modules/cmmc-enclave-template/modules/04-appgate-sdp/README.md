# Module: 04-appgate-sdp

Deploys Appgate SDP Zero Trust Network Access infrastructure. Key Vault, SSH key generation, and firewall DNAT rules are fully implemented. **Controller and Gateway VMs are stubbed** — uncomment them in `main.tf` to deploy.

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
- `azurerm_marketplace_agreement` for `cyxtera:appgatesdp-vm:v6_6_gov_vm`
- Appgate OIDC application registration (`azuread_application`)

## Completing the Module

### Step 1: Accept the marketplace agreement

The image is confirmed available in Azure Government (`cyxtera:appgatesdp-vm:v6_6_gov_vm:6.6.0`). Accept the agreement before deploying:

```hcl
resource "azurerm_marketplace_agreement" "appgate" {
  publisher = "cyxtera"
  offer     = "appgatesdp-vm"
  plan      = "v6_6_gov_vm"
}
```

### Step 2: Uncomment VM resources

Uncomment the VM resources in `main.tf` — `source_image_reference` and `plan {}` are already populated with the correct values.

## Post-Deployment Configuration

After VMs are deployed, run the scripts in `./scripts/` in this order:

1. `./scripts/provision-appgate.sh` — orchestrates all steps below end-to-end
2. `./scripts/seed-controller.sh` — initialize controller
3. `./scripts/seed-gateway.sh` — initialize gateway
4. `./scripts/enable-full-tunnel-default-site.sh` — default site routing
5. `./scripts/create-oidc-idp.sh` — OIDC identity provider setup
6. `./scripts/create-full-tunnel-entitlement.sh` — entitlements
7. `./scripts/create-tunnel-policy.sh` — tunnel policies
8. `./scripts/create-client-profile.sh` — client profiles

## Usage

```hcl
module "appgate_sdp" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/cmmc-enclave-template/modules/04-appgate-sdp?ref=v2.9.2"

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
