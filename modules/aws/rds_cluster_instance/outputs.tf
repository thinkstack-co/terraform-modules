output "id" {
  value = ["${rds_cluster_instance.cluster_instances.*.id}"]
}
