# Bootstrap Guide: One-Time Customer Setup

Complete these steps once per customer deployment before creating the customer Terraform repo. These steps are not automated by Terraform — they establish the foundation that Terraform will build on.

---

## Prerequisites

- Azure CLI installed and logged into Azure Government
- GitHub CLI (`gh`) installed and authenticated
- Access to the customer's Azure Government subscription
- Global Administrator or appropriate privileged role in the customer's Entra ID tenant

---

## Step 1: Set Azure Government Cloud

```bash
az cloud set --name AzureUSGovernment
az login --tenant <customer-tenant-id>
az account set --subscription <customer-subscription-id>
```

---

## Step 2: Create Service Principal

```bash
az ad sp create-for-rbac \
  --name "tf-<customer-name>-sp" \
  --role Contributor \
  --scopes /subscriptions/<subscription-id> \
  --output json
```

Save the output — you will need `appId`, `password`, and `tenant` for OIDC configuration.

### Grant additional permissions

The service principal needs more than Contributor to manage identity and RBAC resources:

```bash
SP_OBJECT_ID=$(az ad sp show --id <appId> --query id -o tsv)

# User Access Administrator — for RBAC assignments at subscription scope
az role assignment create \
  --assignee-object-id $SP_OBJECT_ID \
  --assignee-principal-type ServicePrincipal \
  --role "User Access Administrator" \
  --scope /subscriptions/<subscription-id>

# Cloud Application Administrator — for Entra ID app registrations
# Uses unified RBAC API (works even if the role has never been activated in the tenant)
az rest --method POST \
  --uri "https://graph.microsoft.us/v1.0/roleManagement/directory/roleAssignments" \
  --headers "Content-Type=application/json" \
  --body "{\"principalId\": \"$SP_OBJECT_ID\", \"roleDefinitionId\": \"158c047a-c907-4556-b7ef-446551a6b5f7\", \"directoryScopeId\": \"/\"}"
```

---

## Step 3: Configure OIDC Federated Credentials

OIDC allows GitHub Actions to authenticate without long-lived client secrets.

```bash
APP_ID=$(az ad app show --id <appId> --query appId -o tsv)

# For the main branch (apply workflow)
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:thinkstack-co/cmmc-<customer>-enclave:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# For pull requests (plan workflow)
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-pr",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:thinkstack-co/cmmc-<customer>-enclave:pull_request",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

---

## Step 4: Register Resource Providers

New Azure Government subscriptions require resource providers to be registered before use.
Azure returns a misleading `SubscriptionNotFound` error if you skip this step.

```bash
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.DesktopVirtualization
az provider register --namespace Microsoft.RecoveryServices

# Wait for all to reach Registered state (~1 min each)
for ns in Microsoft.Storage Microsoft.Network Microsoft.Compute Microsoft.KeyVault Microsoft.DesktopVirtualization Microsoft.RecoveryServices; do
  echo "$ns: $(az provider show --namespace $ns --query registrationState -o tsv)"
done
```

Re-run the check until all show `Registered` before proceeding.

---

## Step 5: Create Remote State Storage

```bash
# Resource group
az group create \
  --name "<customer>-tfstate-rg" \
  --location usgovarizona

# Storage account (Standard GRS for state resilience)
az storage account create \
  --name "<customer>tfstate001" \
  --resource-group "<customer>-tfstate-rg" \
  --location usgovarizona \
  --sku Standard_GRS \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

# Enable blob versioning and soft delete
az storage account blob-service-properties update \
  --account-name "<customer>tfstate001" \
  --resource-group "<customer>-tfstate-rg" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 90

# Create state container
az storage container create \
  --name tfstate \
  --account-name "<customer>tfstate001" \
  --auth-mode login

# Grant SP access to state storage
az role assignment create \
  --assignee-object-id $SP_OBJECT_ID \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope $(az storage account show --name "<customer>tfstate001" --resource-group "<customer>-tfstate-rg" --query id -o tsv)
```

---

## Step 6: Configure GitHub Repository

```bash
# Create customer repo
gh repo create thinkstack-co/cmmc-<customer>-enclave --private

# Set GitHub secrets for OIDC
gh secret set AZURE_CLIENT_ID --body "<appId>" --repo thinkstack-co/cmmc-<customer>-enclave
gh secret set AZURE_TENANT_ID --body "<tenant-id>" --repo thinkstack-co/cmmc-<customer>-enclave
gh secret set AZURE_SUBSCRIPTION_ID --body "<subscription-id>" --repo thinkstack-co/cmmc-<customer>-enclave
gh secret set TF_VAR_vm_admin_password --body "<password>" --repo thinkstack-co/cmmc-<customer>-enclave
```

---

## Step 7: Configure GitHub Environments

1. Go to the customer repo → Settings → Environments
2. Create environment `cmmc-production`
3. Add required reviewers (minimum 2: Network Coverage admin + customer IT contact)
4. Restrict deployments to `main` branch only
5. Create environment `cmmc-plan` (no reviewers required — for PR plan previews)

---

## Step 8: Update backend.tf

In the customer repo's `backend.tf`, replace placeholder values:

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

---

## Summary Checklist

- [ ] Azure Government cloud set and logged in
- [ ] Service principal created with Contributor + User Access Administrator + Cloud Application Administrator
- [ ] OIDC federated credentials configured for `main` branch and pull requests
- [ ] Resource providers registered (Storage, Network, Compute, KeyVault, DesktopVirtualization, RecoveryServices)
- [ ] State storage account created (Standard GRS, blob versioning, soft delete 90d)
- [ ] SP granted Storage Blob Data Contributor on state storage account
- [ ] GitHub repo created with AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID, TF_VAR_vm_admin_password secrets
- [ ] GitHub Environments configured (cmmc-production with required reviewers, cmmc-plan)
- [ ] backend.tf updated in customer repo
