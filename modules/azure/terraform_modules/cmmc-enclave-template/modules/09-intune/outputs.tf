output "bitlocker_policy_id" {
  description = "ID of the BitLocker device configuration policy."
  value       = msgraph_resource.bitlocker.output.id
}

output "defender_policy_id" {
  description = "ID of the Windows Defender device configuration policy."
  value       = msgraph_resource.defender.output.id
}

output "firewall_policy_id" {
  description = "ID of the Windows Firewall device configuration policy."
  value       = msgraph_resource.firewall.output.id
}

output "compliance_policy_id" {
  description = "ID of the device compliance policy."
  value       = msgraph_resource.compliance_windows.output.id
}
