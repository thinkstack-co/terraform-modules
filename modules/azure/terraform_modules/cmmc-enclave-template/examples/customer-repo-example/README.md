# Customer Repo Example

This directory shows how a customer-specific deployment repo should be structured when referencing the `cmmc-enclave-template` module library.

**This example is for reference only — do not deploy directly from this directory.**

## How to Use

1. Create a new private repo: `gh repo create NetworkCoverage/cmmc-<customer>-enclave --private`
2. Copy the files in this directory into the new repo as a starting point
3. Update `backend.tf` with the customer's state storage account details
4. Update `?ref=v1.0.0` in all module `source` strings to pin the desired template version
5. Copy `terraform.tfvars.example` to `terraform.tfvars`, fill in values
6. Set `TF_VAR_vm_admin_password` as an environment variable or GitHub secret
7. Complete bootstrap steps: see [`docs/bootstrap.md`](../../docs/bootstrap.md)

## Files

| File | Purpose |
|---|---|
| `versions.tf` | Provider version constraints |
| `providers.tf` | Provider configurations for Azure Government |
| `backend.tf` | Remote state backend (update placeholder values) |
| `variables.tf` | All input variable declarations |
| `main.tf` | Module calls with dependency wiring |
| `outputs.tf` | Key deployment outputs |
| `terraform.tfvars.example` | Example variable values (copy → terraform.tfvars) |
