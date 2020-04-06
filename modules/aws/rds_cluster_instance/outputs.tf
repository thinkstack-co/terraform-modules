output "id" {
  value = aws_rds_cluster_instance.cluster_instances[*].id
}
