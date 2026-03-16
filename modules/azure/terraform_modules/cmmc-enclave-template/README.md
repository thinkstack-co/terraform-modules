# cmmc-enclave-template

A Terraform module library for deploying a **CMMC GCC High Secure Enclave** on Microsoft Azure Government. This repo is a **template/library** — it is never deployed directly. Customer deployments live in separate repos that reference these modules.

---

## Overview

This library codifies the Network Coverage CMMC GCC High deployment standard into reusable, versioned Terraform modules. Each module corresponds to a step in the deployment SOPs and can be referenced independently or as a full stack.

**Target environment:** Microsoft Azure Government (`usgovernment`)

**Compliance posture:** CMMC Level 2/3, GCC High

**Key technologies:**

- Microsoft Entra ID (Azure AD) with PIM and Conditional Access
- Azure Firewall Premium with IDPS
- Appgate SDP (Zero Trust Network Access)
- Azure Virtual Desktop (AVD) with FSLogix
- Azure Image Builder (golden image pipeline)
- Microsoft Intune device management (pending Azure Gov provider support)

---

## Architecture

```text
Customer Repo
└── main.tf
    ├── module "entra"               → 01-entra        (Identity & access)
    ├── module "mgmt_vnet"           → 02-mgmt-vnet    (Firewall, Bastion, routing)
    ├── module "prod_vnet"           → 03-prod-vnet    (Customer VNet, peering)
    ├── module "appgate_sdp"         → 04-appgate-sdp  (ZTNA — partial, see note)
    ├── module "avd"                 → 05-avd          (Host pools, workspaces)
    ├── module "storage"             → 06-storage      (FSLogix + backup)
    ├── module "vm_imaging"          → 07-vm-imaging   (Compute gallery)
    ├── module "session_hosts_mgmt"  → 08-session-hosts (Mgmt AVD VMs)
    ├── module "session_hosts_prod"  → 08-session-hosts (Prod AVD VMs)
    ├── module "image_builder"       → 10-image-builder (AIB pipeline)
    └── module "intune"              → 09-intune       (Device policies — disabled)

Dependency chain:
01 → 02 → 03 ──┐
           04 ──┤
                ├→ 05 → 08a (mgmt)
                ├→ 06      → 08b (prod)
                └→ 07 → 10
                   09 (disabled — Azure Gov OIDC not yet supported)
```

> **Note on 04-appgate-sdp:** The Appgate SDP VM resources are stubbed pending marketplace image availability verification in Azure Government. Key Vault and firewall rules are fully implemented. See [`docs/appgate-image.md`](docs/appgate-image.md).
>
> **Note on 09-intune:** Disabled — `microsoft/msgraph ~> 0.3.0` does not support Azure Government OIDC (`InvalidCloudInstance`). Re-enable when a Gov-compatible provider version is available.

---

## Prerequisites

Before using this library, ensure the following are in place for the target customer tenant:

- [ ] Azure Government subscription
- [ ] Microsoft Entra ID P2 or Microsoft Entra Governance license (required for PIM)
- [ ] Terraform >= 1.9.0 installed locally
- [ ] Azure CLI installed and logged in to Azure Government (`az cloud set --name AzureUSGovernment`)
- [ ] GitHub CLI (`gh`) for repo management
- [ ] Service principal created with appropriate permissions (see [Bootstrap Guide](docs/bootstrap.md))

---

## Versioning

This library uses **semantic versioning** via git tags. Customer repos must always pin a specific version using `?ref=`:

```hcl
source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/cmmc-enclave-template/modules/02-mgmt-vnet?ref=v2.9.2"
```

Pinning to a tag ensures customer deployments are not affected by changes to this library until explicitly upgraded. Never use `?ref=main` in production.

---

## Bootstrap (One-Time per Customer)

Before creating a customer repo, complete the one-time setup documented in [`docs/bootstrap.md`](docs/bootstrap.md):

1. Create a service principal with the required permissions
2. Configure OIDC federated credentials for GitHub Actions
3. Create a remote state storage account in Azure Government
4. Configure GitHub Environments with required reviewers

---

## Customer Repo Setup

### 1. Create the customer repo

```bash
gh repo create thinkstack-co/cmmc-<customer>-enclave --private
cd cmmc-<customer>-enclave
```

### 2. Create `versions.tf`

```hcl
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
  }
}
```

### 3. Create `providers.tf`

```hcl
provider "azurerm" {
  environment = "usgovernment"
  use_oidc    = true
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
}

provider "azuread" {
  environment = "usgovernment"
  use_oidc    = true
}

provider "azapi" {
  environment = "usgovernment"
  use_oidc    = true
}

provider "tls" {}
provider "random" {}
```

> **Note:** Do not set `tenant_id` or `subscription_id` in provider blocks. These are resolved automatically from `ARM_TENANT_ID` and `ARM_SUBSCRIPTION_ID` environment variables (set as TFC workspace variables or GitHub secrets). Use `data "azurerm_client_config" "current"` in `main.tf` to reference them in module calls.

### 4. Reference modules

Copy [`examples/customer-repo-example/main.tf`](examples/customer-repo-example/main.tf) as a starting point and update `?ref=` tags to the desired version.

### 5. Configure backend

Create `backend.tf` pointing to the remote state backend:

```hcl
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "<your-tfc-org>"
    workspaces {
      name = "<customer>_azure_cmmc_infrastructure"
    }
  }
}
```

### 6. Set variable values in TFC

In the TFC workspace → **Variables**, add:

- **Terraform variables**: `customer_name`, `storage_account_name`, `location`, `environment`, `admin_upns` (HCL), `admin_source_ips` (HCL), `vm_admin_password` (sensitive)
- **Environment variables** (all sensitive): `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`, `ARM_ENVIRONMENT` = `usgovernment`

Never commit secrets to the repo. See the full variable reference in [`examples/customer-repo-example/README.md`](examples/customer-repo-example/README.md).

---

## Module Reference

| Module | Purpose | Key Inputs | Key Outputs |
| --- | --- | --- | --- |
| [01-entra](modules/01-entra/) | Entra ID groups, PIM, conditional access | `tenant_id`, `customer_name`, `admin_upns` | Group IDs, CA policy IDs |
| [02-mgmt-vnet](modules/02-mgmt-vnet/) | Management VNet, Firewall Premium, Bastion | `resource_group_name`, `location`, `mgmt_vnet_cidr` | `vnet_id`, `firewall_private_ip`, `subnet_ids` |
| [03-prod-vnet](modules/03-prod-vnet/) | Production VNet, peering to mgmt | `mgmt_vnet_id`, `firewall_private_ip` | `vnet_id`, `subnet_ids` |
| [04-appgate-sdp](modules/04-appgate-sdp/) | ZTNA — Key Vault + firewall rules (VMs stubbed) | `ztna_subnet_id`, `firewall_policy_id` | `key_vault_id` |
| [05-avd](modules/05-avd/) | AVD host pools, workspaces, scaling | `log_analytics_workspace_id`, `avd_users_group_id` | Host pool IDs, registration tokens |
| [06-storage](modules/06-storage/) | FSLogix storage, backup vault | `allowed_subnet_ids`, `customer_name` | `fslogix_unc_path`, `storage_account_key` |
| [07-vm-imaging](modules/07-vm-imaging/) | Azure Compute Gallery, image definitions | `gallery_name`, `image_definitions` | `gallery_id`, `image_definition_ids` |
| [08-session-hosts](modules/08-session-hosts/) | Entra-joined AVD session host VMs | `host_pool_id`, `registration_token`, `gallery_image_id` | `vm_ids`, `private_ips` |
| [09-intune](modules/09-intune/) | BitLocker, Defender, Firewall, compliance policies (**disabled — Azure Gov OIDC unsupported**) | `tenant_id`, `target_group_ids` | Policy IDs |
| [10-image-builder](modules/10-image-builder/) | Azure Image Builder — Win11 Multi-Session + M365 Apps golden image | `gallery_image_definition_id`, `subscription_id` | `template_name`, `template_id` |

---

## Deployment Order

Follow the numbered module sequence. Each step depends on the previous:

1. **[01-entra](modules/01-entra/)** — Groups, PIM, conditional access policies
2. **[02-mgmt-vnet](modules/02-mgmt-vnet/)** — Management network + firewall
3. **[03-prod-vnet](modules/03-prod-vnet/)** — Production network + peering
4. **[04-appgate-sdp](modules/04-appgate-sdp/)** — ZTNA (parallel with 03)
5. **[05-avd](modules/05-avd/)** — Host pools and workspaces
6. **[06-storage](modules/06-storage/)** — FSLogix storage (parallel with 05)
7. **[07-vm-imaging](modules/07-vm-imaging/) + [10-image-builder](modules/10-image-builder/)** — Image gallery + AIB template
8. **Trigger image build** — `az image builder run` (manual, ~60-90 min)
9. **[08-session-hosts](modules/08-session-hosts/)** — Mgmt + prod session host VMs (requires gallery image)
10. **[09-intune](modules/09-intune/)** — Device policies (disabled pending Azure Gov provider support)

See [`docs/deployment-order.md`](docs/deployment-order.md) for full detail and `-target` commands.

---

## Contributing

- Branch naming: `ben/<description>` for Network Coverage team branches
- All changes go through PR — the `validate.yml` workflow must pass
- **Breaking changes** (variable renames, output removals, resource replacements) require a **major version bump** and entry in `CHANGELOG.md`
- Non-breaking additions require a minor version bump; patches for fixes
- After merging, create a git tag: `git tag v1.x.x && git push origin v1.x.x`
- Notify customer repo owners when upgrading is recommended
