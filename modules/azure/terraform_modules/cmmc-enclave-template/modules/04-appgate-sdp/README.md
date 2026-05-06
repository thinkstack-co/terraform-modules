# Module: 04-appgate-sdp

Deploys Appgate SDP Zero Trust Network Access on **two separate VMs** — a dedicated Controller and a dedicated Gateway. Key Vault, SSH key generation, Entra ID OIDC app registration, and firewall DNAT rules are fully implemented. VMs are gated behind `deploy_vms = false` until marketplace plan access is confirmed for the target subscription.

## Architecture

```text
Internet
  │
  ├─ TCP/UDP 443  ──→ Firewall PIP[0] (controller DNS label)
  │                     └─ DNAT → Controller VM (private IP)
  │
  └─ TCP/UDP 443  ──→ Firewall PIP[1] (gateway DNS label)
                        └─ DNAT → Gateway VM (private IP)

Controller VM ──(private 172.16.0.x/26)──→ Azure Firewall ──→ Internet
Gateway VM    ──(private 172.16.0.x/26)──→ Azure Firewall ──→ Internet
```

**No VM public IPs.** All inbound client traffic flows through Azure Firewall DNAT. The ZTNA subnet UDR routes all VM egress through the firewall; because inbound arrived via DNAT, the firewall auto-SNATs return traffic — ensuring symmetric routing. VMs with their own public IPs and a UDR cause asymmetric routing (inbound bypasses firewall, return path goes through firewall which has no state → drops).

**SPA (Single Packet Authorization)** uses UDP. Both TCP and UDP DNAT rules on port 443 are required — TCP-only rules drop the SPA knock, causing WolfSSL -308 / connection failure.

**`cz-coredns` internal DNS**: Appgate's DNS resolver ignores `/etc/hosts`. Gateway-to-controller resolution must be set via the controller API (`networking.hosts` in the appliance config) so `cz-coredns` resolves the controller FQDN to its private IP. Without this, the gateway resolves the controller FQDN to the firewall public IP, hairpins through the firewall, and causes asymmetric routing → TCP RST. See [docs/appgate-configuration.md](../../docs/appgate-configuration.md).

---

## Resources Created

- RSA 4096-bit SSH key pair for Controller (stored in Key Vault as `ag-ctl-private-key`)
- RSA 4096-bit SSH key pair for Gateway (stored in Key Vault as `ag-gw-private-key`)
- Azure Key Vault with soft-delete (90 days) and purge protection
- Key Vault access policy for the Terraform service principal
- Marketplace agreement (`cyxtera:appgatesdp-vm:v6_5_vm`)
- Controller NIC on ZTNA subnet (private IP only) — gated by `deploy_vms`
- Controller Linux VM — gated by `deploy_vms`
- Gateway NIC on ZTNA subnet (private IP only) — gated by `deploy_vms`
- Gateway Linux VM — gated by `deploy_vms`
- Firewall policy rule collection group — gated by `deploy_vms`:
  - DNAT rules on PIP[0] (controller): admin UI (8443 TCP), client (443 TCP + UDP), SSH (22 TCP)
  - DNAT rules on PIP[1] (gateway): client (443 TCP + UDP), SSH (22 TCP)
  - Network rules: NTP outbound from ZTNA subnet
- Entra ID application registration for OIDC authentication
- Entra ID service principal for the OIDC app

---

## Marketplace Image

`cyxtera:appgatesdp-vm:v6_5_vm` is confirmed available in Azure Government (`usgovarizona`). The Terraform marketplace agreement resource handles acceptance automatically on first `terraform apply`.

> **Note:** The `v6_6_gov_vm` plan is a private offer and is not available in the commercial Government marketplace. Use `v6_5_vm` (version `6.5.4`).

---

## Usage

```hcl
module "appgate_sdp" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/cmmc-enclave-template/modules/04-appgate-sdp?ref=v2.9.2"

  resource_group_name        = azurerm_resource_group.ztna.name
  location                   = var.location
  customer_name              = var.customer_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  ztna_subnet_id             = module.mgmt_vnet.subnet_ids["ztna"]
  firewall_policy_id         = module.mgmt_vnet.firewall_policy_id
  firewall_public_ip         = module.mgmt_vnet.firewall_public_ip
  gateway_firewall_public_ip = module.mgmt_vnet.firewall_public_ip_2
  source_admin_ips           = var.admin_source_ips
  deploy_vms                 = true
  tags                       = local.common_tags
}
```

---

## Inputs

| Name                         | Type         | Default            | Description                                     |
| ---------------------------- | ------------ | ------------------ | ----------------------------------------------- |
| `resource_group_name`        | string       | required           | Resource group to deploy into                   |
| `location`                   | string       | `usgovarizona`     | Azure Government region                         |
| `customer_name`              | string       | required           | Customer name (used in Entra app display name)  |
| `tenant_id`                  | string       | required           | Entra ID tenant ID (Key Vault access policy)    |
| `ztna_subnet_id`             | string       | required           | ZTNA subnet resource ID (from 02-mgmt-vnet)     |
| `firewall_policy_id`         | string       | required           | Firewall policy resource ID (from 02-mgmt-vnet) |
| `firewall_public_ip`         | string       | required           | Firewall PIP[0] — controller DNAT destination   |
| `gateway_firewall_public_ip` | string       | required           | Firewall PIP[1] — gateway DNAT destination      |
| `source_admin_ips`           | list(string) | required           | IPs allowed SSH and admin UI access (8443)      |
| `controller_vm_size`         | string       | `Standard_B2ls_v2` | Controller VM size                              |
| `gateway_vm_size`            | string       | `Standard_B2ls_v2` | Gateway VM size                                 |
| `deploy_vms`                 | bool         | `false`            | Deploy Controller and Gateway VMs               |
| `tags`                       | map(string)  | `{}`               | Resource tags                                   |

---

## Outputs

| Name                    | Description                                                                    |
| ----------------------- | ------------------------------------------------------------------------------ |
| `key_vault_id`          | Key Vault resource ID                                                          |
| `key_vault_name`        | Key Vault name                                                                 |
| `oidc_client_id`        | Client (application) ID of the Entra OIDC app registration                     |
| `controller_private_ip` | Controller VM private IP (null when `deploy_vms = false`)                      |
| `controller_fqdn`       | Controller FQDN via firewall PIP[0] DNS label (null when `deploy_vms = false`) |
| `gateway_private_ip`    | Gateway VM private IP (null when `deploy_vms = false`)                         |
| `gateway_fqdn`          | Gateway FQDN via firewall PIP[1] DNS label (null when `deploy_vms = false`)    |

---

## Post-Deployment Configuration

After `terraform apply` with `deploy_vms = true`, Appgate requires manual configuration:

1. Retrieve SSH keys from Key Vault
2. Seed the Controller via Bastion SSH
3. Set `networking.hosts` on the gateway appliance config via controller API (required — see architecture note above)
4. Seed the Gateway
5. Configure OIDC identity provider in the controller admin UI
6. Grant admin consent for the OIDC app in Entra ID (`portal.azure.us`)
7. Create client profiles, policies, and entitlements

See the full guide: [docs/appgate-configuration.md](../../docs/appgate-configuration.md)
