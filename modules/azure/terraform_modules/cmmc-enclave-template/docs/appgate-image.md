# Appgate SDP: Marketplace Image Verification

The `04-appgate-sdp` module stubs out the Controller and Gateway VMs pending verification of Appgate marketplace image availability in Azure Government. This document describes how to verify availability and complete the implementation.

---

## Step 1: Verify Marketplace Availability

```bash
az cloud set --name AzureUSGovernment
az login

# List all Appgate images
az vm image list \
  --publisher cyxtera \
  --all \
  --location usgovarizona \
  --output table
```

**If results are returned:** The marketplace image is available. Proceed to [Option A](#option-a-marketplace-image).

**If no results:** The image is not available in Azure Government. Proceed to [Option B](#option-b-vendor-vhd).

---

## Option A: Marketplace Image

### 1. Note the image details from the list command output

You will need: `Publisher`, `Offer`, `Sku`, `Version`

### 2. Accept the marketplace agreement

Add to `modules/04-appgate-sdp/main.tf`:

```hcl
resource "azurerm_marketplace_agreement" "appgate_ctl" {
  publisher = "cyxtera"
  offer     = "<offer-from-step-1>"
  plan      = "<sku-from-step-1>"
}

resource "azurerm_marketplace_agreement" "appgate_gw" {
  publisher = "cyxtera"
  offer     = "<offer-from-step-1-gateway>"
  plan      = "<sku-from-step-1-gateway>"
}
```

### 3. Uncomment VM resources in `main.tf`

Uncomment the `azurerm_public_ip`, `azurerm_network_interface`, and `azurerm_linux_virtual_machine` blocks for both Controller and Gateway.

### 4. Set image reference

In each VM resource, set:

```hcl
source_image_reference {
  publisher = "cyxtera"
  offer     = "<offer>"
  sku       = "<sku>"
  version   = "latest"
}

plan {
  name      = "<sku>"
  product   = "<offer>"
  publisher = "cyxtera"
}
```

### 5. Update DNAT rule IP addresses

After applying, replace the placeholder private IPs in the DNAT rules with the actual NIC private IPs:

```hcl
translated_address = azurerm_network_interface.controller.private_ip_address
```

---

## Option B: Vendor VHD

### 1. Obtain VHD from Appgate

Contact Appgate (now known as Xurrent/Broadcom) to obtain a VHD for Azure Government deployment.

### 2. Upload VHD to Azure Government

```bash
# Create storage account for VHD upload
az storage account create \
  --name appgatevhd<random> \
  --resource-group <rg> \
  --location usgovarizona \
  --sku Standard_LRS

# Upload VHD (large file — use azcopy for best performance)
azcopy copy \
  "<local-vhd-path>" \
  "https://appgatevhd<random>.blob.core.usgovcloudapi.net/vhds/appgate-controller.vhd" \
  --blob-type PageBlob
```

### 3. Create managed image resource

Add to `modules/04-appgate-sdp/main.tf`:

```hcl
resource "azurerm_image" "appgate_controller" {
  name                = "${local.name_prefix}-ag-ctl-img"
  location            = var.location
  resource_group_name = var.resource_group_name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = "https://appgatevhd<random>.blob.core.usgovcloudapi.net/vhds/appgate-controller.vhd"
  }
}

resource "azurerm_image" "appgate_gateway" {
  name                = "${local.name_prefix}-ag-gw-img"
  location            = var.location
  resource_group_name = var.resource_group_name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = "https://appgatevhd<random>.blob.core.usgovcloudapi.net/vhds/appgate-gateway.vhd"
  }
}
```

### 4. Uncomment and update VM resources

In each VM resource, use `source_image_id` instead of `source_image_reference`:

```hcl
source_image_id = azurerm_image.appgate_controller.id
# No plan {} block required for custom images
```

---

## After VMs Are Deployed

Update outputs in `modules/04-appgate-sdp/outputs.tf` — uncomment the CTL/GW IP outputs.

Then run the Appgate configuration scripts in sequence. See [deployment-order.md](deployment-order.md#appgate-sdp-post-deployment).
