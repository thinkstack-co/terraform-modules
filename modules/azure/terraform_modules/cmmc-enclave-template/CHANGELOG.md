# Changelog

All notable changes to this module library will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

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

### Known Limitations

- `04-appgate-sdp`: Controller and Gateway VMs are stubbed pending Appgate marketplace image verification in Azure Government. See `docs/appgate-image.md`.
