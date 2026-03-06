output "mgmt_vnet_id" {
  description = "Management VNet resource ID."
  value       = module.mgmt_vnet.vnet_id
}

output "prod_vnet_id" {
  description = "Production VNet resource ID."
  value       = module.prod_vnet.vnet_id
}

output "firewall_private_ip" {
  description = "Azure Firewall private IP."
  value       = module.mgmt_vnet.firewall_private_ip
}

output "avd_mgmt_host_pool_name" {
  description = "Management AVD host pool name."
  value       = module.avd.mgmt_host_pool_name
}

output "avd_customer_host_pool_name" {
  description = "Customer AVD host pool name."
  value       = module.avd.customer_host_pool_name
}

output "fslogix_unc_path" {
  description = "FSLogix profile share UNC path."
  value       = module.storage.fslogix_unc_path
}

output "compute_gallery_name" {
  description = "Azure Compute Gallery name."
  value       = module.vm_imaging.gallery_name
}

output "key_vault_name" {
  description = "Appgate Key Vault name."
  value       = module.appgate_sdp.key_vault_name
}

output "session_host_names" {
  description = "AVD session host VM names."
  value       = module.session_hosts.vm_names
}
