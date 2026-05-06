# Module: 10-image-builder

Provisions an Azure Image Builder (AIB) pipeline that produces a Windows 11 Multi-Session golden image with Windows Updates and M365 Apps pre-installed, then publishes it to the Azure Compute Gallery. The build is **manually triggered** — Terraform creates the template definition only.

## Resources Created

- User-assigned managed identity (`<customer>-aib-id`)
- Role assignment: Contributor on the imaging resource group (allows AIB to create staging resources and write gallery image versions)
- AIB image template (`<customer>-aib-win11-m365`) with:
  - Source: `MicrosoftWindowsDesktop / windows-11 / win11-24h2-avd` (latest)
  - Customizer 1: Windows Update (all non-preview updates)
  - Customizer 2: PowerShell — M365 Apps for Enterprise via Office Deployment Tool (64-bit, Current Channel, SharedComputerLicensing)
  - Distribution: SharedImage → Compute Gallery `win11-multisession` definition

## Provider Notes

This module uses the `azure/azapi` provider (`~> 2.0`) via `azapi_resource` to manage `Microsoft.VirtualMachineImages/imageTemplates@2024-02-01`. The `hashicorp/azurerm` provider does not include a native `azurerm_image_builder_template` resource.

The `azapi` provider must be configured for Azure Government:

```hcl
provider "azapi" {
  environment = "usgovernment"
  use_oidc    = true
}
```

## Triggering a Build

After `terraform apply`, trigger a build manually:

```bash
az image builder run \
  --name <customer>-aib-win11-m365 \
  --resource-group <customer>-imaging-rg \
  --no-wait

# Monitor progress (~60-90 min)
az image builder show \
  --name <customer>-aib-win11-m365 \
  --resource-group <customer>-imaging-rg \
  --query "lastRunStatus" \
  --output table
```

When `runState` reaches `Succeeded`, a new image version is published to the gallery. Session hosts can then be deployed.

To rebuild (e.g., monthly patching), run the same `az image builder run` command again — a new version is created each time.

## Usage

```hcl
module "image_builder" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/cmmc-enclave-template/modules/10-image-builder?ref=v2.9.2"

  resource_group_name         = azurerm_resource_group.imaging.name
  location                    = var.location
  customer_name               = var.customer_name
  subscription_id             = data.azurerm_client_config.current.subscription_id
  gallery_image_definition_id = module.vm_imaging.image_definition_ids["win11-multisession"]
  tags                        = local.common_tags

  depends_on = [module.vm_imaging, azurerm_resource_group.imaging]
}
```

## Inputs

| Name                          | Type        | Default          | Description                                                  |
| ----------------------------- | ----------- | ---------------- | ------------------------------------------------------------ |
| `resource_group_name`         | string      | required         | Resource group for AIB resources                             |
| `location`                    | string      | required         | Azure Government region                                      |
| `customer_name`               | string      | required         | Short customer name for resource naming                      |
| `subscription_id`             | string      | required         | Azure subscription ID (for role assignment scope)            |
| `gallery_image_definition_id` | string      | required         | Compute Gallery image definition resource ID to publish into |
| `source_image_sku`            | string      | `win11-24h2-avd` | Marketplace SKU for the Win11 Multi-Session base image       |
| `tags`                        | map(string) | `{}`             | Tags applied to all resources                                |

## Outputs

| Name                    | Description                                                      |
| ----------------------- | ---------------------------------------------------------------- |
| `identity_id`           | Resource ID of the AIB user-assigned managed identity            |
| `identity_principal_id` | Principal ID of the AIB managed identity                         |
| `template_name`         | Name of the AIB image template (use with `az image builder run`) |
| `template_id`           | Resource ID of the AIB image template                            |
