# Outputs for the experimental aws_backup_gold module
#
# We will expose plan IDs, vault ARNs, and other details here as
# the implementation is built out.

output "gold_plan_id" {
  description = "ID of the Gold backup plan (placeholder, will be wired once resources are added)"
  value       = aws_backup_plan.gold.id
}

output "gold_selection_id" {
  description = "ID of the tag-based backup selection for the Gold plan"
  value       = aws_backup_selection.gold_tag_selection.id
}
