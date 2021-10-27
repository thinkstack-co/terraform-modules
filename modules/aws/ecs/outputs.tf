output "ecs_cluster_id" {
  value       = concat(aws_ecs_cluster.ecs.*.id, [""])[0]
  description = "ID of the cluster"
}

output "ecs_cluster_arn" {
  value       = concat(aws_ecs_cluster.ecs.*.arn, [""])[0]
  description = "Arn of the cluster"
}

output "ecs_cluster_name" {
  value       = var.name
  description = "name of the cluster"
}