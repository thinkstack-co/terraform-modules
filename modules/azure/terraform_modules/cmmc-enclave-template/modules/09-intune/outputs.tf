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

output "rdp_redirection_policy_id" {
  description = "ID of the Configure device and resource redirection policy."
  value       = msgraph_resource.settings_catalog_rdp_redirection.output.id
}

output "gpu_acceleration_policy_id" {
  description = "ID of the Configure GPU acceleration policy. Null if gpu_vm_group_id was not set."
  value       = var.gpu_vm_group_id != null ? msgraph_resource.settings_catalog_gpu_acceleration[0].output.id : null
}

output "onedrive_policy_id" {
  description = "ID of the Configure OneDrive settings policy."
  value       = msgraph_resource.settings_catalog_onedrive.output.id
}

output "ntp_policy_id" {
  description = "ID of the Configure Windows NTP client policy."
  value       = msgraph_resource.settings_catalog_ntp.output.id
}

output "password_reveal_policy_id" {
  description = "ID of the Disable password reveal policy."
  value       = msgraph_resource.settings_catalog_password_reveal.output.id
}

output "aip_policy_id" {
  description = "ID of the Enable Azure Information Protection add-in policy."
  value       = msgraph_resource.settings_catalog_aip.output.id
}

output "logon_banner_policy_id" {
  description = "ID of the Enable interactive logon banner policy."
  value       = msgraph_resource.settings_catalog_logon_banner.output.id
}

output "screen_capture_policy_id" {
  description = "ID of the Enable screen capture protection policy."
  value       = msgraph_resource.settings_catalog_screen_capture.output.id
}

output "lock_screen_policy_id" {
  description = "ID of the Set lock screen inactivity timer policy."
  value       = msgraph_resource.device_config_lock_screen.output.id
}

output "password_policy_id" {
  description = "ID of the Set password policy."
  value       = msgraph_resource.device_config_password_policy.output.id
}
