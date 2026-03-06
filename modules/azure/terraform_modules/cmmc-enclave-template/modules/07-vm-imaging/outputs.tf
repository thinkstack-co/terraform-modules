output "gallery_id" {
  description = "Resource ID of the Azure Compute Gallery."
  value       = azurerm_shared_image_gallery.main.id
}

output "gallery_name" {
  description = "Name of the Azure Compute Gallery."
  value       = azurerm_shared_image_gallery.main.name
}

output "image_definition_ids" {
  description = "Map of image definition name → resource ID."
  value       = { for k, v in azurerm_shared_image.definitions : k => v.id }
}
