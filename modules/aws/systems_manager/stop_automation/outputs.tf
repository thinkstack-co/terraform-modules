output "maintenance_window_id" {
  description = "The ID of the maintenance window."
  value       = aws_ssm_maintenance_window.maintenance_window.id
}

output "maintenance_window_target_id" {
  description = "The ID of the maintenance window target."
  value       = aws_ssm_maintenance_window_target.target.id
}
