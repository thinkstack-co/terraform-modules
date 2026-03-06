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

output "ca_policy_ids" {
  description = "Map of conditional access policy name → policy ID."
  value = {
    require_mfa      = azuread_conditional_access_policy.require_mfa.id
    block_non_us     = azuread_conditional_access_policy.block_non_us.id
    block_legacy_auth = azuread_conditional_access_policy.block_legacy_auth.id
  }
}
