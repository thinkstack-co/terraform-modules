output "dx_connection_id" {
  value        = concat(aws_dx_connection.dx.*.id, [""])[0]
  description  = "The ID of the connection"
}

output "dx_connection_bandwidth" {
  value       = concat(aws_dx_connection.dx.*.bandwidth, [""])[0]
  description = "Bandwidth of the connection"
}

output "dx_connection_arn" {
  value         = concat(aws_dx_connnection.dx.*.arn, [""])[0]
  description   = "The ARN of the connnection"
}

output "dx_connection_name" {
  value         = concat(aws_dx_connection.dx.*.name, [""])[0]
  description   = "The connection name"
}