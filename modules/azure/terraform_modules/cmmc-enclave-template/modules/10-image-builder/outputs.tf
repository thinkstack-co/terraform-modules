output "identity_id" {
  description = "Resource ID of the AIB user-assigned managed identity."
  value       = azurerm_user_assigned_identity.aib.id
}

output "identity_principal_id" {
  description = "Principal ID of the AIB managed identity."
  value       = azurerm_user_assigned_identity.aib.principal_id
}

output "template_name" {
  description = "Name of the AIB image template (use with 'az image builder run')."
  value       = azapi_resource.aib_template.name
}

output "template_id" {
  description = "Resource ID of the AIB image template."
  value       = azapi_resource.aib_template.id
}
