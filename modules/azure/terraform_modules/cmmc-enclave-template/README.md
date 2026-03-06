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
- Microsoft Intune device management

---

## Architecture

```text
Customer Repo
└── main.tf
    ├── module "entra"          → 01-entra        (Identity & access)
    ├── module "mgmt_vnet"      → 02-mgmt-vnet    (Firewall, Bastion, routing)
    ├── module "prod_vnet"      → 03-prod-vnet    (Customer VNet, peering)
    ├── module "appgate_sdp"    → 04-appgate-sdp  (ZTNA — partial, see note)
    ├── module "avd"            → 05-avd          (Host pools, workspaces)
    ├── module "storage"        → 06-storage      (FSLogix + backup)
    ├── module "vm_imaging"     → 07-vm-imaging   (Compute gallery)
    ├── module "session_hosts"  → 08-session-hosts (AVD VMs)
    └── module "intune"         → 09-intune       (Device policies)

Dependency chain:
01 → 02 → 03 ──┐
           04 ──┤
                ├→ 05 → 08
                ├→ 06 ──┘
                └→ 07
                   09 (independent, depends on 01)
```

> **Note on 04-appgate-sdp:** The Appgate SDP VM resources are stubbed pending marketplace image availability verification in Azure Government. Key Vault and firewall rules are fully implemented. See [`docs/appgate-image.md`](docs/appgate-image.md).

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
source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/02-mgmt-vnet?ref=v1.0.0"
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
gh repo create NetworkCoverage/cmmc-<customer>-enclave --private
cd cmmc-<customer>-enclave
```

### 2. Create `providers.tf`

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
    microsoft365 = {
      source  = "hashicorp/microsoft365"
      version = "~> 1.0"
    }
  }
}

provider "azurerm" {
  environment     = "usgovernment"
  use_oidc        = true
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
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
  tenant_id   = var.tenant_id
}

provider "tls" {}
provider "random" {}

provider "microsoft365" {
  tenant_id   = var.tenant_id
  environment = "usgov"
  use_oidc    = true
}
```

### 3. Reference modules

Copy [`examples/customer-repo-example/main.tf`](examples/customer-repo-example/main.tf) as a starting point and update `?ref=` tags to the desired version.

### 4. Configure backend

Create `backend.tf` pointing to the state storage account created during bootstrap:

```hcl
terraform {
  backend "azurerm" {
    environment          = "usgovernment"
    resource_group_name  = "<customer>-tfstate-rg"
    storage_account_name = "<customer>tfstate001"
    container_name       = "tfstate"
    key                  = "cmmc-enclave.tfstate"
    use_oidc             = true
  }
}
```

### 5. Set variable values

Copy `examples/customer-repo-example/terraform.tfvars.example` to `terraform.tfvars` and fill in values. Secrets (passwords, keys) are injected via `TF_VAR_` environment variables or pulled from a Key Vault data source — never committed.

---

## Module Reference

| Module | Purpose | Key Inputs | Key Outputs |
|---|---|---|---|
| [01-entra](modules/01-entra/) | Entra ID groups, PIM, conditional access | `tenant_id`, `customer_name`, `admin_upns` | Group IDs, CA policy IDs |
| [02-mgmt-vnet](modules/02-mgmt-vnet/) | Management VNet, Firewall Premium, Bastion | `resource_group_name`, `location`, `mgmt_vnet_cidr` | `vnet_id`, `firewall_private_ip`, `subnet_ids` |
| [03-prod-vnet](modules/03-prod-vnet/) | Production VNet, peering to mgmt | `mgmt_vnet_id`, `firewall_private_ip` | `vnet_id`, `subnet_ids` |
| [04-appgate-sdp](modules/04-appgate-sdp/) | ZTNA — Key Vault + firewall rules (VMs stubbed) | `ztna_subnet_id`, `firewall_policy_id` | `key_vault_id` |
| [05-avd](modules/05-avd/) | AVD host pools, workspaces, scaling | `log_analytics_workspace_id`, `avd_users_group_id` | Host pool IDs, registration tokens |
| [06-storage](modules/06-storage/) | FSLogix storage, backup vault | `allowed_subnet_ids`, `customer_name` | `fslogix_unc_path`, `storage_account_key` |
| [07-vm-imaging](modules/07-vm-imaging/) | Azure Compute Gallery, image definitions | `gallery_name`, `image_definitions` | `gallery_id`, `image_definition_ids` |
| [08-session-hosts](modules/08-session-hosts/) | Entra-joined AVD session host VMs | `host_pool_id`, `registration_token`, `gallery_image_id` | `vm_ids`, `private_ips` |
| [09-intune](modules/09-intune/) | BitLocker, Defender, Firewall, compliance policies | `tenant_id`, `target_group_ids` | Policy IDs |

---

## Deployment Order

Follow the numbered module sequence. Each step depends on the previous:

1. **[01-entra](modules/01-entra/)** — Groups, PIM, conditional access policies
2. **[02-mgmt-vnet](modules/02-mgmt-vnet/)** — Management network + firewall
3. **[03-prod-vnet](modules/03-prod-vnet/)** — Production network + peering
4. **[04-appgate-sdp](modules/04-appgate-sdp/)** — ZTNA (parallel with 03)
5. **[05-avd](modules/05-avd/)** — Host pools and workspaces
6. **[06-storage](modules/06-storage/)** — FSLogix storage (parallel with 05)
7. **[07-vm-imaging](modules/07-vm-imaging/)** — Image gallery (parallel with 05)
8. **[08-session-hosts](modules/08-session-hosts/)** — Session host VMs
9. **[09-intune](modules/09-intune/)** — Device policies (can run after 01)

See [`docs/deployment-order.md`](docs/deployment-order.md) for full detail and `-target` commands.

---

## Contributing

- Branch naming: `ben/<description>` for Network Coverage team branches
- All changes go through PR — the `validate.yml` workflow must pass
- **Breaking changes** (variable renames, output removals, resource replacements) require a **major version bump** and entry in `CHANGELOG.md`
- Non-breaking additions require a minor version bump; patches for fixes
- After merging, create a git tag: `git tag v1.x.x && git push origin v1.x.x`
- Notify customer repo owners when upgrading is recommended
