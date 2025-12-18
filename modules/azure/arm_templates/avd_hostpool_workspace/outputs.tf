######################################
# Azure ARM Template Deployment Outputs
######################################

output "hostpool_name" {
  description = "Name of the AVD host pool (from ARM template output)"
  value       = try(jsondecode(azurerm_resource_group_template_deployment.avd.output_content).hostpoolName.value, null)
}

output "hostpool_id" {
  description = "Resource ID of the AVD host pool (from ARM template output)"
  value       = try(jsondecode(azurerm_resource_group_template_deployment.avd.output_content).hostpoolId.value, null)
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace (from ARM template output)"
  value       = try(jsondecode(azurerm_resource_group_template_deployment.avd.output_content).logAnalyticsWorkspaceName.value, null)
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace (from ARM template output)"
  value       = try(jsondecode(azurerm_resource_group_template_deployment.avd.output_content).logAnalyticsWorkspaceId.value, null)
}

output "desktop_application_group_name" {
  description = "Name of the Desktop Application Group (DAG) (from ARM template output)"
  value       = try(jsondecode(azurerm_resource_group_template_deployment.avd.output_content).desktopApplicationGroupName.value, null)
}

output "desktop_application_group_id" {
  description = "Resource ID of the Desktop Application Group (DAG) (from ARM template output)"
  value       = try(jsondecode(azurerm_resource_group_template_deployment.avd.output_content).desktopApplicationGroupId.value, null)
}

output "workspace_name" {
  description = "Name of the AVD workspace (from ARM template output)"
  value       = try(jsondecode(azurerm_resource_group_template_deployment.avd.output_content).workspaceName.value, null)
}

output "workspace_id" {
  description = "Resource ID of the AVD workspace (from ARM template output)"
  value       = try(jsondecode(azurerm_resource_group_template_deployment.avd.output_content).workspaceId.value, null)
}

output "deployment_id" {
  description = "Resource ID of the ARM template deployment"
  value       = azurerm_resource_group_template_deployment.avd.id
}

output "deployment_output_content" {
  description = "Raw output content JSON string returned by the ARM template deployment"
  value       = azurerm_resource_group_template_deployment.avd.output_content
}
