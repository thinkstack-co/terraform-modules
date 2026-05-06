# ---------------------------------------------------------------------------
# Route Table — force traffic through Azure Firewall
# ---------------------------------------------------------------------------

resource "azurerm_route_table" "mgmt" {
  name                = "${local.name_prefix}-rt-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  bgp_route_propagation_enabled = false
}

resource "azurerm_route" "default_to_firewall" {
  name                   = "default-to-firewall"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.mgmt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.mgmt.ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "ztna" {
  subnet_id      = azurerm_subnet.ztna.id
  route_table_id = azurerm_route_table.mgmt.id
}

resource "azurerm_subnet_route_table_association" "mgmt_avd" {
  subnet_id      = azurerm_subnet.mgmt_avd.id
  route_table_id = azurerm_route_table.mgmt.id
}
