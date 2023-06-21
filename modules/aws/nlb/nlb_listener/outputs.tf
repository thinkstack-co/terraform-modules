output "listener_arn" {
  description = "The ARN of the Listener"
  value       = aws_alb_listener.listener.arn
}

output "listener_load_balancer_arn" {
  description = "The ARN of the Load Balancer to which this listener is attached"
  value       = aws_alb_listener.listener.load_balancer_arn
}
