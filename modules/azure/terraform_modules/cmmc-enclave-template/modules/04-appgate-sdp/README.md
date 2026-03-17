# Module: 04-appgate-sdp

Deploys Appgate SDP Zero Trust Network Access on a **single combined appliance** — one VM running both the Controller and Gateway roles. Key Vault, SSH key generation, and firewall DNAT rules are fully implemented. The VM is gated behind `deploy_vms = false` until marketplace plan access is confirmed.

## Resources Created

- RSA 4096-bit SSH key pair (stored in Key Vault as `ag-ctl-private-key`)
- Azure Key Vault with soft-delete and purge protection
- Marketplace agreement (`cyxtera:appgatesdp-vm:v6_6_gov_vm`) — gated by `deploy_vms`
- Combined Controller+Gateway VM (public IP, NIC, Linux VM) — gated by `deploy_vms`
- Firewall DNAT rules: `combined-admin-ui` (8443), `combined-https` (443), `combined-ssh` (22)
- Firewall network rules: NTP outbound

## Marketplace Blocker

`v6_6_gov_vm` is a **private offer**. The subscription must be added to the plan's allowed audience by Cyxtera before `deploy_vms = true` will work.

Contact Cyxtera/Appgate support with:
- Azure subscription ID
- Tenant ID
- Request access to: `cyxtera:appgatesdp-vm:v6_6_gov_vm` in Azure Government

## Post-Deployment Configuration

After `deploy_vms = true` applies successfully, retrieve the SSH key and run:

```bash
# Get SSH key from Key Vault
az keyvault secret show \
  --vault-name <kv-name> \
  --name ag-ctl-private-key \
  --query value -o tsv > ./appgate.pem
chmod 600 ./appgate.pem

# Provision combined controller + gateway
cd Scripts/
./provision-appgate.sh \
  <customer_shortname> \
  <admin_password> \
  <appgate_fqdn> \
  <appgate_private_ip> \
  <entra_tenant_id> \
  <oidc_app_client_id>
```

`provision-appgate.sh` seeds the controller, waits for health, then seeds the gateway role on the same VM, and completes the remaining configuration steps.

## Usage

```hcl
module "appgate_sdp" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/cmmc-enclave-template/modules/04-appgate-sdp?ref=v2.9.2"

  resource_group_name = azurerm_resource_group.ztna.name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  ztna_subnet_id      = module.mgmt_vnet.subnet_ids["ztna"]
  firewall_policy_id  = module.mgmt_vnet.firewall_policy_id
  firewall_public_ip  = module.mgmt_vnet.firewall_public_ip
  source_admin_ips    = var.admin_source_ips
  deploy_vms          = false  # set true after marketplace access confirmed
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
| `source_admin_ips` | list(string) | required | Admin IPs allowed SSH/admin-UI access |
| `controller_vm_size` | string | `Standard_B2s` | Combined appliance VM size |
| `deploy_vms` | bool | `false` | Deploy VM (requires marketplace access) |
| `tags` | map(string) | `{}` | Resource tags |

## Outputs

| Name | Description |
|---|---|
| `key_vault_id` | Key Vault resource ID |
| `key_vault_name` | Key Vault name |
| `appgate_private_ip` | Private IP of the combined VM (null when deploy_vms = false) |
| `appgate_fqdn` | FQDN of the combined VM public IP (null when deploy_vms = false) |
