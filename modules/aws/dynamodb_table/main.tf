terraform {
  required_version = ">= 0.12.0"
}

resource "aws_dynamodb_table" "this" {
  attribute              = var.attribute
  global_secondary_index = var.global_secondary_index
  hash_key               = var.hash_key
  local_secondary_index  = var.local_secondary_index
  name                   = var.name
  point_in_time_recovery = var.point_in_time_recovery
  range_key              = var.range_key
  read_capacity          = var.read_capacity
  server_side_encryption = var.server_side_encryption
  stream_enabled         = var.stream_enabled
  tags                   = var.tags
  ttl                    = var.ttl
  write_capacity         = var.write_capacity
}
