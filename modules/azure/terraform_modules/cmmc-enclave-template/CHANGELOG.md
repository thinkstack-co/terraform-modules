# Changelog

All notable changes to this module library will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added

- **`10-image-builder`**: New module — Azure Image Builder pipeline deploying Win11 Multi-Session + Windows Update + M365 Apps to the Compute Gallery. Manually triggered via `az image builder run`. Uses `azure/azapi ~> 2.0` provider (`azapi_resource` for `Microsoft.VirtualMachineImages/imageTemplates@2024-02-01`).
- `azapi` provider (`azure/azapi ~> 2.0`) added to customer repo example and top-level README setup guide.
- `mgmt_session_host_count` variable (default: 2) added to customer repo example — separate count for management vs. production session hosts.
- Validation blocks on `customer_name` (1–20 lowercase alphanumeric/hyphen) and `storage_account_name` (3–24 lowercase alphanumeric, no hyphens).

### Changed

- **`05-avd`**: Fixed deprecated `application_id` → `client_id` in `azuread_service_principal` data source for the AVD first-party service principal.
- **`08-session-hosts`**: Split single `module "session_hosts"` into `module "session_hosts_mgmt"` (mgmt VNet subnet, mgmt host pool, `mgmt_session_host_count`) and `module "session_hosts_prod"` (prod VNet subnet, customer host pool, `session_host_count`). Customer repo example and docs updated accordingly.
- **`06-storage`**: `allowed_subnet_ids` now includes both `mgmt_avd` and prod AVD subnets so FSLogix is reachable from both session host sets.
- **`02-mgmt-vnet`**: Added `service_endpoints = ["Microsoft.Storage"]` to `mgmt_avd` subnet (required for storage account network rules).
- **`04-appgate-sdp`**: Fixed Key Vault name exceeding 24-character limit — `name_prefix` now derived from truncated resource group name instead of full location string.
- **`01-entra`**: Fixed `t.template_id` → `t.object_id` in `azuread_directory_role_templates` reference. Added `assignable_to_role = true` to PIM-eligible and RBAC groups (required for Entra ID role assignments).
- **`02-mgmt-vnet` / `03-prod-vnet`**: Removed unsupported `VMProtectionAlerts` diagnostic log category (not available in Azure Government).
- **`02-mgmt-vnet` firewall**: Removed unsupported `AzureFirewallThreatIntel` and `AzureFirewallIDPSSignature` diagnostic categories. Replaced web category firewall rules (unsupported in Azure Gov) with FQDN tag-based rules (`WindowsUpdate`, `WindowsDiagnostics`, `MicrosoftActiveProtectionService`).
- Provider blocks: Removed `tenant_id` and `subscription_id` from `azurerm` and `azuread` provider blocks — resolved via `ARM_TENANT_ID`/`ARM_SUBSCRIPTION_ID` environment variables. Module calls use `data "azurerm_client_config" "current"` instead.
- Replaced `microsoft365` provider references with `azapi` throughout customer repo example.

### Removed

- `tenant_id` and `subscription_id` input variables from customer repo example (replaced by `data "azurerm_client_config" "current"`).
- `microsoft365` / `msgraph` provider from all example and documentation files.

### Disabled

- **`09-intune`**: `microsoft/msgraph ~> 0.3.0` does not support Azure Government OIDC (`InvalidCloudInstance` error). Module remains in the library but is commented out in the customer repo example and deployment guide. Re-enable when a Gov-compatible provider version is available.

### Known Limitations

- `04-appgate-sdp`: Controller and Gateway VMs are stubbed pending Appgate marketplace image verification in Azure Government. See `docs/appgate-image.md`.
- `09-intune`: Disabled — Azure Government OIDC not supported by `microsoft/msgraph ~> 0.3.0`.

---

## [Unreleased — Prior]

### Changed

- Remove deprecated `graceful_shutdown` from azurerm provider `features.virtual_machine` block (dropped in azurerm 4.x; no replacement)
- Replace deprecated `metric` with `enabled_metric` in all `azurerm_monitor_diagnostic_setting` resources (removed in v5.0)
- Update all module source URLs from `NetworkCoverage/cmmc-enclave-template` to `thinkstack-co/terraform-modules` to reflect new repo location
- Update version ref from `v1.0.0` to `v2.9.2`
- Update GitHub org references in docs from `NetworkCoverage` to `thinkstack-co`

### Added

- Initial module library scaffolding
- Modules: 01-entra, 02-mgmt-vnet, 03-prod-vnet, 04-appgate-sdp (partial), 05-avd, 06-storage, 07-vm-imaging, 08-session-hosts, 09-intune
- Customer repo example in `examples/customer-repo-example`
- Bootstrap and deployment documentation in `docs/`
- GitHub Actions validation workflow
