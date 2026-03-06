# Module: 07-vm-imaging

Creates an Azure Compute Gallery and image definitions for Windows 11 session hosts (Gen2, Trusted Launch). Image versions are populated externally — Terraform manages only the gallery structure.

## Resources Created

- Azure Compute Gallery
- Image definitions (configurable, defaults to win11-multisession + win11-singlesession)

## Image Version Workflow

Terraform does not manage image versions. Populate them via:

1. **Azure Image Builder (recommended):** Set up an AIB pipeline that builds images and pushes versions to this gallery.

2. **Manual capture:**

   ```bash
   # After configuring the base VM:
   az vm generalize --resource-group <rg> --name <vm-name>
   az sig image-version create \
     --resource-group <rg> \
     --gallery-name <gallery-name> \
     --gallery-image-definition win11-multisession \
     --gallery-image-version 1.0.0 \
     --managed-image /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Compute/images/<img>
   ```

## Usage

```hcl
module "vm_imaging" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/07-vm-imaging?ref=v1.0.0"

  resource_group_name = azurerm_resource_group.imaging.name
  location            = var.location
  gallery_name        = "${var.customer_name}Gallery"
  tags                = local.common_tags
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `resource_group_name` | string | required | Resource group name |
| `location` | string | required | Azure Government region |
| `gallery_name` | string | required | Compute Gallery name |
| `image_definitions` | map(object) | see variables | Image definition configurations |
| `tags` | map(string) | `{}` | Resource tags |

## Outputs

| Name | Description |
|---|---|
| `gallery_id` | Compute Gallery resource ID |
| `gallery_name` | Compute Gallery name |
| `image_definition_ids` | Map of definition name → resource ID |
