output "bitlocker_policy_id" {
  description = "ID of the BitLocker device configuration policy."
  value       = microsoft365_graph_beta_device_management_configuration_policy.bitlocker.id
}

output "defender_policy_id" {
  description = "ID of the Windows Defender device configuration policy."
  value       = microsoft365_graph_beta_device_management_configuration_policy.defender.id
}

output "firewall_policy_id" {
  description = "ID of the Windows Firewall device configuration policy."
  value       = microsoft365_graph_beta_device_management_configuration_policy.firewall.id
}

output "compliance_policy_id" {
  description = "ID of the device compliance policy."
  value       = microsoft365_graph_beta_device_management_compliance_policy.windows.id
}
