output "maintenance_window_id_stop" {
  description = "The ID of the maintenance window for stopping instances."
  value       = aws_ssm_maintenance_window.maintenance_window_stop.id
}

output "maintenance_window_id_start" {
  description = "The ID of the maintenance window for starting instances."
  value       = aws_ssm_maintenance_window.maintenance_window_start.id
}

output "maintenance_window_target_id_stop" {
  description = "The ID of the maintenance window target for stopping instances."
  value       = aws_ssm_maintenance_window_target.target_stop.id
}

output "maintenance_window_target_id_start" {
  description = "The ID of the maintenance window target for starting instances."
  value       = aws_ssm_maintenance_window_target.target_start.id
}
