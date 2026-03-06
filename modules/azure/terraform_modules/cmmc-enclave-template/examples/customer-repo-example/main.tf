locals {
  common_tags = {
    customer    = var.customer_name
    environment = var.environment
    compliance  = "CMMC-L2"
    managed_by  = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Resource Groups
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "mgmt" {
  name     = "${var.customer_name}-mgmt-rg"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "prod" {
  name     = "${var.customer_name}-prod-rg"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "ztna" {
  name     = "${var.customer_name}-ztna-rg"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "avd" {
  name     = "${var.customer_name}-avd-rg"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "storage" {
  name     = "${var.customer_name}-storage-rg"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "imaging" {
  name     = "${var.customer_name}-imaging-rg"
  location = var.location
  tags     = local.common_tags
}

# ---------------------------------------------------------------------------
# 01 - Entra ID: Groups, PIM, Conditional Access
# ---------------------------------------------------------------------------

module "entra" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/01-entra?ref=v1.0.0"

  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  customer_name   = var.customer_name
  admin_upns      = var.admin_upns
  tags            = local.common_tags
}

# ---------------------------------------------------------------------------
# 02 - Management VNet: Firewall, Bastion, Subnets, Routing
# ---------------------------------------------------------------------------

module "mgmt_vnet" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/02-mgmt-vnet?ref=v1.0.0"

  resource_group_name = azurerm_resource_group.mgmt.name
  location            = var.location
  mgmt_vnet_cidr      = var.mgmt_vnet_cidr
  tags                = local.common_tags

  depends_on = [azurerm_resource_group.mgmt]
}

# ---------------------------------------------------------------------------
# 03 - Production VNet: Customer Subnets, Peering
# ---------------------------------------------------------------------------

module "prod_vnet" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/03-prod-vnet?ref=v1.0.0"

  resource_group_name      = azurerm_resource_group.prod.name
  location                 = var.location
  customer_name            = var.customer_name
  prod_vnet_cidr           = var.prod_vnet_cidr
  mgmt_vnet_id             = module.mgmt_vnet.vnet_id
  mgmt_vnet_name           = module.mgmt_vnet.vnet_name
  mgmt_resource_group_name = azurerm_resource_group.mgmt.name
  firewall_private_ip      = module.mgmt_vnet.firewall_private_ip
  tags                     = local.common_tags

  depends_on = [module.mgmt_vnet, azurerm_resource_group.prod]
}

# ---------------------------------------------------------------------------
# 04 - Appgate SDP: Key Vault, SSH Keys, Firewall Rules (VMs stubbed)
# ---------------------------------------------------------------------------

module "appgate_sdp" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/04-appgate-sdp?ref=v1.0.0"

  resource_group_name = azurerm_resource_group.ztna.name
  location            = var.location
  tenant_id           = var.tenant_id
  ztna_subnet_id      = module.mgmt_vnet.subnet_ids["ztna"]
  firewall_policy_id  = module.mgmt_vnet.firewall_policy_id
  firewall_public_ip  = module.mgmt_vnet.firewall_public_ip
  source_admin_ips    = var.admin_source_ips
  tags                = local.common_tags

  depends_on = [module.mgmt_vnet, azurerm_resource_group.ztna]
}

# ---------------------------------------------------------------------------
# 05 - AVD: Host Pools, Workspaces, Scaling, Diagnostics
# ---------------------------------------------------------------------------

module "avd" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/05-avd?ref=v1.0.0"

  resource_group_name        = azurerm_resource_group.avd.name
  location                   = var.location
  customer_name              = var.customer_name
  log_analytics_workspace_id = module.mgmt_vnet.log_analytics_workspace_id
  avd_users_group_id         = module.entra.sspr_group_id
  customer_host_pool_type    = var.customer_host_pool_type
  customer_max_sessions      = var.customer_max_sessions
  tags                       = local.common_tags

  depends_on = [module.entra, module.mgmt_vnet, azurerm_resource_group.avd]
}

# ---------------------------------------------------------------------------
# 06 - Storage: FSLogix Premium FileStorage + Backup Vault
# ---------------------------------------------------------------------------

module "storage" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/06-storage?ref=v1.0.0"

  resource_group_name  = azurerm_resource_group.storage.name
  location             = var.location
  customer_name        = var.customer_name
  storage_account_name = var.storage_account_name
  allowed_subnet_ids   = [module.mgmt_vnet.subnet_ids["mgmt_avd"]]
  fslogix_share_size_gb = var.fslogix_share_size_gb
  tags                 = local.common_tags

  depends_on = [module.mgmt_vnet, azurerm_resource_group.storage]
}

# ---------------------------------------------------------------------------
# 07 - VM Imaging: Azure Compute Gallery + Image Definitions
# ---------------------------------------------------------------------------

module "vm_imaging" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/07-vm-imaging?ref=v1.0.0"

  resource_group_name = azurerm_resource_group.imaging.name
  location            = var.location
  gallery_name        = "${var.customer_name}Gallery"
  tags                = local.common_tags

  depends_on = [azurerm_resource_group.imaging]
}

# ---------------------------------------------------------------------------
# 08 - Session Hosts: AVD VMs, Entra Join, FSLogix
# ---------------------------------------------------------------------------

module "session_hosts" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/08-session-hosts?ref=v1.0.0"

  resource_group_name     = azurerm_resource_group.avd.name
  location                = var.location
  customer_name           = var.customer_name
  host_count              = var.session_host_count
  vm_size                 = var.vm_size
  subnet_id               = module.mgmt_vnet.subnet_ids["mgmt_avd"]
  gallery_image_id        = module.vm_imaging.image_definition_ids["win11-multisession"]
  host_pool_id            = module.avd.customer_host_pool_id
  registration_token      = module.avd.customer_registration_token
  fslogix_storage_account = module.storage.storage_account_name
  fslogix_storage_key     = module.storage.storage_account_key
  admin_username          = var.vm_admin_username
  admin_password          = var.vm_admin_password
  tags                    = local.common_tags

  depends_on = [module.avd, module.storage, module.vm_imaging]
}

# ---------------------------------------------------------------------------
# 09 - Intune: Device Config + Compliance Policies
# ---------------------------------------------------------------------------

module "intune" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/09-intune?ref=v1.0.0"

  tenant_id        = var.tenant_id
  target_group_ids = [module.entra.sspr_group_id]
  tags             = local.common_tags

  depends_on = [module.entra]
}
