# Intune Device Policies: Cloud Shell Deployment

The `09-intune` Terraform module is disabled for Azure Government because `microsoft/msgraph ~> 0.3.0` does not support Azure Government OIDC (`InvalidCloudInstance`). Use the bash scripts in `modules/09-intune/scripts/` to deploy the same policies via `az rest` from Azure Cloud Shell.

---

## Policies Deployed

| Policy | Type | Endpoint |
| --- | --- | --- |
| CMMC - BitLocker Encryption | Configuration | `deviceManagement/configurationPolicies` |
| CMMC - Windows Defender Antivirus | Configuration | `deviceManagement/configurationPolicies` |
| CMMC - Windows Firewall | Configuration | `deviceManagement/configurationPolicies` |
| CMMC - Windows Device Compliance | Compliance | `deviceManagement/compliancePolicies` |

All policies are assigned to the Entra group(s) you specify. The scripts call `https://graph.microsoft.us/beta` — the Azure Government Microsoft Graph endpoint.

---

## Prerequisites

- Azure Cloud Shell authenticated to the correct Azure Government tenant
- Target Entra group IDs (groups to assign policies to)
- `jq` available in Cloud Shell (pre-installed)

Verify your environment:

```bash
az cloud show --query name -o tsv
# Must return: AzureUSGovernment

az account show --query tenantId -o tsv
# Must return the correct tenant ID
```

If not targeting Azure Government:

```bash
az cloud set --name AzureUSGovernment
az login
```

---

## Get Target Group IDs

Policies should be assigned to the AVD users group (or whichever group contains managed devices). Retrieve the group ID using one of these methods:

**From Terraform outputs** (run in the customer repo directory):

```bash
terraform output -json | jq -r '."module.entra.sspr_group_id".value'
```

**By group display name via Azure CLI:**

```bash
az ad group list \
  --display-name "<customer>-avd-users" \
  --query "[0].id" -o tsv
```

---

## Deploy Policies

### 1. Download the deploy script to Cloud Shell

```bash
curl -sSL "https://raw.githubusercontent.com/thinkstack-co/terraform-modules/v2.9.2/modules/azure/terraform_modules/cmmc-enclave-template/modules/09-intune/scripts/deploy-intune-policies.sh" \
  -o deploy-intune-policies.sh
chmod +x deploy-intune-policies.sh
```

### 2. Run the script

```bash
GROUP_ID="<entra-group-object-id>"

./deploy-intune-policies.sh --group-id "$GROUP_ID"
```

Assign to multiple groups:

```bash
./deploy-intune-policies.sh \
  --group-id "<group-id-1>" \
  --group-id "<group-id-2>"
```

Optional parameters:

```bash
./deploy-intune-policies.sh \
  --group-id "$GROUP_ID" \
  --encryption-method xtsAes256 \   # default: xtsAes128
  --grace-period-hours 24           # default: 0 (immediate block)
```

### 3. Expected output

```
Environment: AzureUSGovernment
Graph endpoint: https://graph.microsoft.us/beta
Group IDs: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Encryption method: xtsAes128
Grace period hours: 0

==> BitLocker Configuration Policy
    Created (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
    Assigned to 1 group(s).
==> Windows Defender Configuration Policy
    Created (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
    Assigned to 1 group(s).
==> Windows Firewall Configuration Policy
    Created (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
    Assigned to 1 group(s).
==> Windows Device Compliance Policy
    Created (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
    Assigned to 1 group(s).

Done.
Policy                                   ID
------                                   --
CMMC - BitLocker Encryption              xxxxxxxx-...
CMMC - Windows Defender Antivirus        xxxxxxxx-...
CMMC - Windows Firewall                  xxxxxxxx-...
CMMC - Windows Device Compliance         xxxxxxxx-...

Verify at: https://intune.microsoft.us → Devices → Configuration / Compliance policies
```

The script is **idempotent** — if any policy already exists with the same name, it is skipped and its existing ID is reported.

---

## Verification

1. Open `https://intune.microsoft.us`
2. Navigate to **Devices** → **Configuration policies** — confirm 3 policies with names matching `CMMC - *`
3. Navigate to **Devices** → **Compliance policies** — confirm 1 policy named `CMMC - Windows Device Compliance`
4. Open each policy → **Properties** → confirm the target group appears under Assignments

On a managed Windows device:

```powershell
# Force a policy sync
Start-Process "ms-settings:workplace"
# or via MDM: Sync in Settings → Accounts → Access work or school
```

Check compliance status in the Intune portal within 15 minutes of sync.

---

## Re-running

The script is safe to re-run at any time. Existing policies are detected by display name and skipped. To update a policy, either delete it first (using `remove-intune-policies.sh`) or modify it in the Intune portal.

---

## Remove Policies

To delete all CMMC policies (e.g., when redeploying or cleaning up):

```bash
curl -sSL "https://raw.githubusercontent.com/thinkstack-co/terraform-modules/v2.9.2/modules/azure/terraform_modules/cmmc-enclave-template/modules/09-intune/scripts/remove-intune-policies.sh" \
  -o remove-intune-policies.sh
chmod +x remove-intune-policies.sh

./remove-intune-policies.sh
# Prompts for confirmation before deleting
```

---

## When Terraform Support Becomes Available

Re-enable the `09-intune` module in the customer repo `main.tf` when a Microsoft Graph Terraform provider version supporting Azure Government OIDC is available.

Track provider support: [terraform-provider-msgraph releases](https://github.com/microsoft/terraform-provider-msgraph/releases)

Before re-enabling, delete the manually-created policies using `remove-intune-policies.sh` to avoid conflicts with Terraform state.
