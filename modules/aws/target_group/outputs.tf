output "arn" {
  description = "The Amazon Resource Name (ARN) of the target group"
  value       = aws_lb_target_group.this.arn
}

output "name" {
  description = "The name of the target group"
  value       = aws_lb_target_group.this.name
}

output "port" {
  description = "The port number on which the targets receive traffic"
  value       = aws_lb_target_group.this.port
}

output "protocol" {
  description = "The protocol to use for routing traffic to the targets"
  value       = aws_lb_target_group.this.protocol
}

output "health_check_path" {
  description = "The ping path that is the destination on the targets for health checks"
  value       = aws_lb_target_group.this.health_check_path
}

output "health_check_port" {
  description = "The port number to use to connect with the target for health checks"
  value       = aws_lb_target_group.this.health_check_port
}

output "health_check_protocol" {
  description = "The protocol to use for health checks"
  value       = aws_lb_target_group.this.health_check_protocol
}

output "health_check_timeout" {
  description = "The amount of time, in seconds, during which no response means a failed health check"
  value       = aws_lb_target_group.this.health_check_timeout
}

output "health_check_threshold" {
  description = "The number of consecutive health checks that must succeed before considering an unhealthy target healthy"
  value       = aws_lb_target_group.this.health_check_threshold
}

output "health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful response from a target"
  value       = aws_lb_target_group.this.health_check_matcher
}
