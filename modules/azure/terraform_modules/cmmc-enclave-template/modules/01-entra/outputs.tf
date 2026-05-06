output "group_ids" {
  description = "Map of group display name → object ID for all created groups."
  value       = { for k, g in azuread_group.pim_eligible : k => g.object_id }
}

output "rbac_group_ids" {
  description = "Map of RBAC group display name → object ID."
  value       = { for k, g in azuread_group.rbac : k => g.object_id }
}

output "sspr_group_id" {
  description = "Object ID of the dynamic SSPR group."
  value       = azuread_group.sspr.object_id
}

output "mfa_exempt_group_id" {
  description = "Object ID of the MFA exempt group."
  value       = azuread_group.mfa_exempt.object_id
}

output "all_users_group_id" {
  description = "Object ID of the All Users dynamic group."
  value       = azuread_group.all_users.object_id
}

output "licensed_users_group_id" {
  description = "Object ID of the Licensed Users dynamic group."
  value       = azuread_group.licensed_users.object_id
}

output "all_windows_devices_group_id" {
  description = "Object ID of the All Windows 10 and Later Devices dynamic group."
  value       = azuread_group.all_windows_devices.object_id
}

output "secure_enclave_location_id" {
  description = "ID of the Secure Enclave named location."
  value       = azuread_named_location.secure_enclave.id
}

output "avd_hosts_group_id" {
  description = "Object ID of the All Azure Virtual Desktop Hosts dynamic group."
  value       = azuread_group.avd_hosts.object_id
}

output "gpu_vms_group_id" {
  description = "Object ID of the GPU-optimized Azure VMs dynamic group."
  value       = azuread_group.gpu_vms.object_id
}

output "ca_policy_ids" {
  description = "Map of conditional access policy name → policy ID."
  value = {
    require_mfa                = azuread_conditional_access_policy.require_mfa.id
    block_non_us               = azuread_conditional_access_policy.block_non_us.id
    block_legacy_auth          = azuread_conditional_access_policy.block_legacy_auth.id
    block_outside_ztna         = azuread_conditional_access_policy.block_outside_ztna.id
    block_non_avd_outside_ztna = azuread_conditional_access_policy.block_non_avd_outside_ztna.id
    avd_reauthentication       = azuread_conditional_access_policy.avd_reauthentication.id
  }
}
