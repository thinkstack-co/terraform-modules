# Appgate SDP: Marketplace Image

The `04-appgate-sdp` module deploys Appgate SDP Controller and Gateway VMs using the Cyxtera marketplace image in Azure Government.

---

## Confirmed Image

| Field     | Value                                |
| --------- | ------------------------------------ |
| Publisher | `cyxtera`                            |
| Offer     | `appgatesdp-vm`                      |
| Plan/SKU  | `v6_5_vm`                            |
| Version   | `6.5.4`                              |
| Region    | `usgovarizona` (confirmed available) |

The Terraform marketplace agreement resource (`azurerm_marketplace_agreement.appgate`) accepts the plan automatically on first `terraform apply`. No manual portal steps required.

Set `deploy_vms = true` in the `04-appgate-sdp` module call to deploy both Controller and Gateway VMs.

> **Note:** The `v6_6_gov_vm` plan is a **private offer** and is not available in the commercial Government marketplace. Do not attempt to use it — use `v6_5_vm`.

---

## Post-Deployment

After VMs are deployed, Appgate requires manual configuration (seeding, OIDC setup, client profiles). See the full guide:

[docs/appgate-configuration.md](appgate-configuration.md)

---

## Verifying Image Availability in a New Subscription

If deploying to a new Azure Government subscription and you need to verify the image is accessible:

```bash
az cloud set --name AzureUSGovernment
az login

az vm image list \
  --publisher cyxtera \
  --offer appgatesdp-vm \
  --all \
  --location usgovarizona \
  --output table
```

If `v6_5_vm` appears in the output, proceed with `deploy_vms = true`. If no results are returned, the subscription may need marketplace access granted — contact Cyxtera/Appgate support with the subscription ID and tenant ID.

---

## Fallback: Vendor VHD (If Marketplace Unavailable)

If the marketplace image becomes unavailable in a future Azure Government region or subscription, obtain a VHD directly from Appgate (now part of Broadcom/Xurrent).

### 1. Upload VHD to Azure Government

```bash
az storage account create \
  --name appgatevhd<random> \
  --resource-group <rg> \
  --location usgovarizona \
  --sku Standard_LRS

azcopy copy \
  "<local-vhd-path>" \
  "https://appgatevhd<random>.blob.core.usgovcloudapi.net/vhds/appgate.vhd" \
  --blob-type PageBlob
```

### 2. Create managed image and update VM resources

Replace `source_image_reference` + `plan` blocks in the VM resources with:

```hcl
source_image_id = azurerm_image.appgate_controller.id
# No plan {} block required for custom images
```

Add `azurerm_image` resources referencing the uploaded VHD blob URIs.
