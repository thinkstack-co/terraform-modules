resource "aws_vpc_peering_connection_accepter" "peer" {
  auto_accept               = var.auto_accept
  tags                      = var.tags
  vpc_peering_connection_id = var.vpc_peering_connection_id
}