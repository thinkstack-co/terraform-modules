# ---------------------------------------------------------------------------
# Azure Bastion
# ---------------------------------------------------------------------------

resource "azurerm_public_ip" "bastion" {
  name                = "${local.name_prefix}-bastion-pip-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "mgmt" {
  name                = "${local.name_prefix}-bastion-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  scale_units         = 2
  tags                = var.tags

  # Standard SKU features
  copy_paste_enabled     = true
  file_copy_enabled      = true
  tunneling_enabled      = true
  shareable_link_enabled = false

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
