# Customer Repo Example

This directory shows how a customer-specific deployment repo should be structured when referencing the `cmmc-enclave-template` module library.

**This example is for reference only — do not deploy directly from this directory.**

## How to Use

1. Create a new private repo: `gh repo create thinkstack-co/cmmc-<customer>-enclave --private`
2. Copy the files in this directory into the new repo as a starting point
3. Update `backend.tf` with the TFC organization and workspace name
4. Update `?ref=v2.9.2` in all module `source` strings to pin the desired template version
5. Set Terraform variables in the TFC workspace (see table below)
6. Set environment variables in the TFC workspace for Azure authentication (see table below)
7. Complete bootstrap steps: see [`docs/bootstrap.md`](../../docs/bootstrap.md)

## Files

| File | Purpose |
| --- | --- |
| `versions.tf` | Provider version constraints |
| `providers.tf` | Provider configurations for Azure Government |
| `backend.tf` | Remote state backend (update TFC org and workspace name) |
| `variables.tf` | All input variable declarations |
| `main.tf` | Module calls with dependency wiring |
| `outputs.tf` | Key deployment outputs |

## TFC Workspace Variables

### Terraform Variables

| Key | Type | Sensitive | Example Value |
| --- | --- | --- | --- |
| `customer_name` | string | No | `acme` |
| `storage_account_name` | string | No | `acmetfstate001` |
| `location` | string | No | `usgovarizona` |
| `environment` | string | No | `production` |
| `admin_upns` | HCL (list) | No | `["admin@acme.onmicrosoft.us"]` |
| `admin_source_ips` | HCL (list) | No | `["203.0.113.10/32"]` |
| `vm_admin_password` | string | **Yes** | `<password>` |

### Environment Variables

| Key | Sensitive | Description |
| --- | --- | --- |
| `ARM_CLIENT_ID` | **Yes** | Service principal app ID |
| `ARM_CLIENT_SECRET` | **Yes** | Service principal secret |
| `ARM_TENANT_ID` | **Yes** | Entra ID tenant ID |
| `ARM_SUBSCRIPTION_ID` | **Yes** | Azure Government subscription ID |
| `ARM_ENVIRONMENT` | **Yes** | `usgovernment` |
