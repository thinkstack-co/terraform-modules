# Outputs expose attributes of aws_dx_connection.dxc consumed by DX virtual
# interfaces and Direct Connect gateway associations.

output "id" {
  description = "The ID of the Direct Connect connection; consumed by aws_dx_private_virtual_interface / gateway associations."
  value       = aws_dx_connection.dxc.id
}

output "arn" {
  description = "The ARN of the Direct Connect connection."
  value       = aws_dx_connection.dxc.arn
}

output "aws_device" {
  description = "The AWS Direct Connect endpoint on which the physical connection terminates."
  value       = aws_dx_connection.dxc.aws_device
}

output "jumbo_frame_capable" {
  description = "Whether the connection supports jumbo frames (9001 MTU)."
  value       = aws_dx_connection.dxc.jumbo_frame_capable
}
