###########################
# State migration (moved blocks)
###########################
# v3 re-keyed every per-AZ resource from count (<=v2.9.2) to for_each on an
# ordinal string key ("0","1",...). These moved blocks rename the old
# count-indexed state ([N]) to the new ordinal key (["N"]) in place, so a
# consumer bumping straight from <=v2.9.2 to v3 migrates with zero destroy.
# Static set covers up to 6 AZs (ordinals 0-5); unmatched entries are no-ops.

# --- Subnets ---
moved {
  from = aws_subnet.private_subnets[0]
  to   = aws_subnet.private_subnets["0"]
}
moved {
  from = aws_subnet.private_subnets[1]
  to   = aws_subnet.private_subnets["1"]
}
moved {
  from = aws_subnet.private_subnets[2]
  to   = aws_subnet.private_subnets["2"]
}
moved {
  from = aws_subnet.private_subnets[3]
  to   = aws_subnet.private_subnets["3"]
}
moved {
  from = aws_subnet.private_subnets[4]
  to   = aws_subnet.private_subnets["4"]
}
moved {
  from = aws_subnet.private_subnets[5]
  to   = aws_subnet.private_subnets["5"]
}

moved {
  from = aws_subnet.public_subnets[0]
  to   = aws_subnet.public_subnets["0"]
}
moved {
  from = aws_subnet.public_subnets[1]
  to   = aws_subnet.public_subnets["1"]
}
moved {
  from = aws_subnet.public_subnets[2]
  to   = aws_subnet.public_subnets["2"]
}
moved {
  from = aws_subnet.public_subnets[3]
  to   = aws_subnet.public_subnets["3"]
}
moved {
  from = aws_subnet.public_subnets[4]
  to   = aws_subnet.public_subnets["4"]
}
moved {
  from = aws_subnet.public_subnets[5]
  to   = aws_subnet.public_subnets["5"]
}

moved {
  from = aws_subnet.dmz_subnets[0]
  to   = aws_subnet.dmz_subnets["0"]
}
moved {
  from = aws_subnet.dmz_subnets[1]
  to   = aws_subnet.dmz_subnets["1"]
}
moved {
  from = aws_subnet.dmz_subnets[2]
  to   = aws_subnet.dmz_subnets["2"]
}
moved {
  from = aws_subnet.dmz_subnets[3]
  to   = aws_subnet.dmz_subnets["3"]
}
moved {
  from = aws_subnet.dmz_subnets[4]
  to   = aws_subnet.dmz_subnets["4"]
}
moved {
  from = aws_subnet.dmz_subnets[5]
  to   = aws_subnet.dmz_subnets["5"]
}

moved {
  from = aws_subnet.db_subnets[0]
  to   = aws_subnet.db_subnets["0"]
}
moved {
  from = aws_subnet.db_subnets[1]
  to   = aws_subnet.db_subnets["1"]
}
moved {
  from = aws_subnet.db_subnets[2]
  to   = aws_subnet.db_subnets["2"]
}
moved {
  from = aws_subnet.db_subnets[3]
  to   = aws_subnet.db_subnets["3"]
}
moved {
  from = aws_subnet.db_subnets[4]
  to   = aws_subnet.db_subnets["4"]
}
moved {
  from = aws_subnet.db_subnets[5]
  to   = aws_subnet.db_subnets["5"]
}

moved {
  from = aws_subnet.mgmt_subnets[0]
  to   = aws_subnet.mgmt_subnets["0"]
}
moved {
  from = aws_subnet.mgmt_subnets[1]
  to   = aws_subnet.mgmt_subnets["1"]
}
moved {
  from = aws_subnet.mgmt_subnets[2]
  to   = aws_subnet.mgmt_subnets["2"]
}
moved {
  from = aws_subnet.mgmt_subnets[3]
  to   = aws_subnet.mgmt_subnets["3"]
}
moved {
  from = aws_subnet.mgmt_subnets[4]
  to   = aws_subnet.mgmt_subnets["4"]
}
moved {
  from = aws_subnet.mgmt_subnets[5]
  to   = aws_subnet.mgmt_subnets["5"]
}

moved {
  from = aws_subnet.workspaces_subnets[0]
  to   = aws_subnet.workspaces_subnets["0"]
}
moved {
  from = aws_subnet.workspaces_subnets[1]
  to   = aws_subnet.workspaces_subnets["1"]
}
moved {
  from = aws_subnet.workspaces_subnets[2]
  to   = aws_subnet.workspaces_subnets["2"]
}
moved {
  from = aws_subnet.workspaces_subnets[3]
  to   = aws_subnet.workspaces_subnets["3"]
}
moved {
  from = aws_subnet.workspaces_subnets[4]
  to   = aws_subnet.workspaces_subnets["4"]
}
moved {
  from = aws_subnet.workspaces_subnets[5]
  to   = aws_subnet.workspaces_subnets["5"]
}

# --- Route tables (per-AZ; public RT is singular, not moved) ---
moved {
  from = aws_route_table.private_route_table[0]
  to   = aws_route_table.private_route_table["0"]
}
moved {
  from = aws_route_table.private_route_table[1]
  to   = aws_route_table.private_route_table["1"]
}
moved {
  from = aws_route_table.private_route_table[2]
  to   = aws_route_table.private_route_table["2"]
}
moved {
  from = aws_route_table.private_route_table[3]
  to   = aws_route_table.private_route_table["3"]
}
moved {
  from = aws_route_table.private_route_table[4]
  to   = aws_route_table.private_route_table["4"]
}
moved {
  from = aws_route_table.private_route_table[5]
  to   = aws_route_table.private_route_table["5"]
}

moved {
  from = aws_route_table.db_route_table[0]
  to   = aws_route_table.db_route_table["0"]
}
moved {
  from = aws_route_table.db_route_table[1]
  to   = aws_route_table.db_route_table["1"]
}
moved {
  from = aws_route_table.db_route_table[2]
  to   = aws_route_table.db_route_table["2"]
}
moved {
  from = aws_route_table.db_route_table[3]
  to   = aws_route_table.db_route_table["3"]
}
moved {
  from = aws_route_table.db_route_table[4]
  to   = aws_route_table.db_route_table["4"]
}
moved {
  from = aws_route_table.db_route_table[5]
  to   = aws_route_table.db_route_table["5"]
}

moved {
  from = aws_route_table.dmz_route_table[0]
  to   = aws_route_table.dmz_route_table["0"]
}
moved {
  from = aws_route_table.dmz_route_table[1]
  to   = aws_route_table.dmz_route_table["1"]
}
moved {
  from = aws_route_table.dmz_route_table[2]
  to   = aws_route_table.dmz_route_table["2"]
}
moved {
  from = aws_route_table.dmz_route_table[3]
  to   = aws_route_table.dmz_route_table["3"]
}
moved {
  from = aws_route_table.dmz_route_table[4]
  to   = aws_route_table.dmz_route_table["4"]
}
moved {
  from = aws_route_table.dmz_route_table[5]
  to   = aws_route_table.dmz_route_table["5"]
}

moved {
  from = aws_route_table.mgmt_route_table[0]
  to   = aws_route_table.mgmt_route_table["0"]
}
moved {
  from = aws_route_table.mgmt_route_table[1]
  to   = aws_route_table.mgmt_route_table["1"]
}
moved {
  from = aws_route_table.mgmt_route_table[2]
  to   = aws_route_table.mgmt_route_table["2"]
}
moved {
  from = aws_route_table.mgmt_route_table[3]
  to   = aws_route_table.mgmt_route_table["3"]
}
moved {
  from = aws_route_table.mgmt_route_table[4]
  to   = aws_route_table.mgmt_route_table["4"]
}
moved {
  from = aws_route_table.mgmt_route_table[5]
  to   = aws_route_table.mgmt_route_table["5"]
}

moved {
  from = aws_route_table.workspaces_route_table[0]
  to   = aws_route_table.workspaces_route_table["0"]
}
moved {
  from = aws_route_table.workspaces_route_table[1]
  to   = aws_route_table.workspaces_route_table["1"]
}
moved {
  from = aws_route_table.workspaces_route_table[2]
  to   = aws_route_table.workspaces_route_table["2"]
}
moved {
  from = aws_route_table.workspaces_route_table[3]
  to   = aws_route_table.workspaces_route_table["3"]
}
moved {
  from = aws_route_table.workspaces_route_table[4]
  to   = aws_route_table.workspaces_route_table["4"]
}
moved {
  from = aws_route_table.workspaces_route_table[5]
  to   = aws_route_table.workspaces_route_table["5"]
}

# --- NAT default routes (per RT) ---
moved {
  from = aws_route.private_default_route_natgw[0]
  to   = aws_route.private_default_route_natgw["0"]
}
moved {
  from = aws_route.private_default_route_natgw[1]
  to   = aws_route.private_default_route_natgw["1"]
}
moved {
  from = aws_route.private_default_route_natgw[2]
  to   = aws_route.private_default_route_natgw["2"]
}
moved {
  from = aws_route.private_default_route_natgw[3]
  to   = aws_route.private_default_route_natgw["3"]
}
moved {
  from = aws_route.private_default_route_natgw[4]
  to   = aws_route.private_default_route_natgw["4"]
}
moved {
  from = aws_route.private_default_route_natgw[5]
  to   = aws_route.private_default_route_natgw["5"]
}

moved {
  from = aws_route.db_default_route_natgw[0]
  to   = aws_route.db_default_route_natgw["0"]
}
moved {
  from = aws_route.db_default_route_natgw[1]
  to   = aws_route.db_default_route_natgw["1"]
}
moved {
  from = aws_route.db_default_route_natgw[2]
  to   = aws_route.db_default_route_natgw["2"]
}
moved {
  from = aws_route.db_default_route_natgw[3]
  to   = aws_route.db_default_route_natgw["3"]
}
moved {
  from = aws_route.db_default_route_natgw[4]
  to   = aws_route.db_default_route_natgw["4"]
}
moved {
  from = aws_route.db_default_route_natgw[5]
  to   = aws_route.db_default_route_natgw["5"]
}

moved {
  from = aws_route.dmz_default_route_natgw[0]
  to   = aws_route.dmz_default_route_natgw["0"]
}
moved {
  from = aws_route.dmz_default_route_natgw[1]
  to   = aws_route.dmz_default_route_natgw["1"]
}
moved {
  from = aws_route.dmz_default_route_natgw[2]
  to   = aws_route.dmz_default_route_natgw["2"]
}
moved {
  from = aws_route.dmz_default_route_natgw[3]
  to   = aws_route.dmz_default_route_natgw["3"]
}
moved {
  from = aws_route.dmz_default_route_natgw[4]
  to   = aws_route.dmz_default_route_natgw["4"]
}
moved {
  from = aws_route.dmz_default_route_natgw[5]
  to   = aws_route.dmz_default_route_natgw["5"]
}

moved {
  from = aws_route.mgmt_default_route_natgw[0]
  to   = aws_route.mgmt_default_route_natgw["0"]
}
moved {
  from = aws_route.mgmt_default_route_natgw[1]
  to   = aws_route.mgmt_default_route_natgw["1"]
}
moved {
  from = aws_route.mgmt_default_route_natgw[2]
  to   = aws_route.mgmt_default_route_natgw["2"]
}
moved {
  from = aws_route.mgmt_default_route_natgw[3]
  to   = aws_route.mgmt_default_route_natgw["3"]
}
moved {
  from = aws_route.mgmt_default_route_natgw[4]
  to   = aws_route.mgmt_default_route_natgw["4"]
}
moved {
  from = aws_route.mgmt_default_route_natgw[5]
  to   = aws_route.mgmt_default_route_natgw["5"]
}

moved {
  from = aws_route.workspaces_default_route_natgw[0]
  to   = aws_route.workspaces_default_route_natgw["0"]
}
moved {
  from = aws_route.workspaces_default_route_natgw[1]
  to   = aws_route.workspaces_default_route_natgw["1"]
}
moved {
  from = aws_route.workspaces_default_route_natgw[2]
  to   = aws_route.workspaces_default_route_natgw["2"]
}
moved {
  from = aws_route.workspaces_default_route_natgw[3]
  to   = aws_route.workspaces_default_route_natgw["3"]
}
moved {
  from = aws_route.workspaces_default_route_natgw[4]
  to   = aws_route.workspaces_default_route_natgw["4"]
}
moved {
  from = aws_route.workspaces_default_route_natgw[5]
  to   = aws_route.workspaces_default_route_natgw["5"]
}

# --- Firewall default routes (per RT) ---
moved {
  from = aws_route.private_default_route_fw[0]
  to   = aws_route.private_default_route_fw["0"]
}
moved {
  from = aws_route.private_default_route_fw[1]
  to   = aws_route.private_default_route_fw["1"]
}
moved {
  from = aws_route.private_default_route_fw[2]
  to   = aws_route.private_default_route_fw["2"]
}
moved {
  from = aws_route.private_default_route_fw[3]
  to   = aws_route.private_default_route_fw["3"]
}
moved {
  from = aws_route.private_default_route_fw[4]
  to   = aws_route.private_default_route_fw["4"]
}
moved {
  from = aws_route.private_default_route_fw[5]
  to   = aws_route.private_default_route_fw["5"]
}

moved {
  from = aws_route.db_default_route_fw[0]
  to   = aws_route.db_default_route_fw["0"]
}
moved {
  from = aws_route.db_default_route_fw[1]
  to   = aws_route.db_default_route_fw["1"]
}
moved {
  from = aws_route.db_default_route_fw[2]
  to   = aws_route.db_default_route_fw["2"]
}
moved {
  from = aws_route.db_default_route_fw[3]
  to   = aws_route.db_default_route_fw["3"]
}
moved {
  from = aws_route.db_default_route_fw[4]
  to   = aws_route.db_default_route_fw["4"]
}
moved {
  from = aws_route.db_default_route_fw[5]
  to   = aws_route.db_default_route_fw["5"]
}

moved {
  from = aws_route.dmz_default_route_fw[0]
  to   = aws_route.dmz_default_route_fw["0"]
}
moved {
  from = aws_route.dmz_default_route_fw[1]
  to   = aws_route.dmz_default_route_fw["1"]
}
moved {
  from = aws_route.dmz_default_route_fw[2]
  to   = aws_route.dmz_default_route_fw["2"]
}
moved {
  from = aws_route.dmz_default_route_fw[3]
  to   = aws_route.dmz_default_route_fw["3"]
}
moved {
  from = aws_route.dmz_default_route_fw[4]
  to   = aws_route.dmz_default_route_fw["4"]
}
moved {
  from = aws_route.dmz_default_route_fw[5]
  to   = aws_route.dmz_default_route_fw["5"]
}

moved {
  from = aws_route.mgmt_default_route_fw[0]
  to   = aws_route.mgmt_default_route_fw["0"]
}
moved {
  from = aws_route.mgmt_default_route_fw[1]
  to   = aws_route.mgmt_default_route_fw["1"]
}
moved {
  from = aws_route.mgmt_default_route_fw[2]
  to   = aws_route.mgmt_default_route_fw["2"]
}
moved {
  from = aws_route.mgmt_default_route_fw[3]
  to   = aws_route.mgmt_default_route_fw["3"]
}
moved {
  from = aws_route.mgmt_default_route_fw[4]
  to   = aws_route.mgmt_default_route_fw["4"]
}
moved {
  from = aws_route.mgmt_default_route_fw[5]
  to   = aws_route.mgmt_default_route_fw["5"]
}

moved {
  from = aws_route.workspaces_default_route_fw[0]
  to   = aws_route.workspaces_default_route_fw["0"]
}
moved {
  from = aws_route.workspaces_default_route_fw[1]
  to   = aws_route.workspaces_default_route_fw["1"]
}
moved {
  from = aws_route.workspaces_default_route_fw[2]
  to   = aws_route.workspaces_default_route_fw["2"]
}
moved {
  from = aws_route.workspaces_default_route_fw[3]
  to   = aws_route.workspaces_default_route_fw["3"]
}
moved {
  from = aws_route.workspaces_default_route_fw[4]
  to   = aws_route.workspaces_default_route_fw["4"]
}
moved {
  from = aws_route.workspaces_default_route_fw[5]
  to   = aws_route.workspaces_default_route_fw["5"]
}

# --- NAT gateways + EIPs ---
moved {
  from = aws_eip.nateip[0]
  to   = aws_eip.nateip["0"]
}
moved {
  from = aws_eip.nateip[1]
  to   = aws_eip.nateip["1"]
}
moved {
  from = aws_eip.nateip[2]
  to   = aws_eip.nateip["2"]
}
moved {
  from = aws_eip.nateip[3]
  to   = aws_eip.nateip["3"]
}
moved {
  from = aws_eip.nateip[4]
  to   = aws_eip.nateip["4"]
}
moved {
  from = aws_eip.nateip[5]
  to   = aws_eip.nateip["5"]
}

moved {
  from = aws_nat_gateway.natgw[0]
  to   = aws_nat_gateway.natgw["0"]
}
moved {
  from = aws_nat_gateway.natgw[1]
  to   = aws_nat_gateway.natgw["1"]
}
moved {
  from = aws_nat_gateway.natgw[2]
  to   = aws_nat_gateway.natgw["2"]
}
moved {
  from = aws_nat_gateway.natgw[3]
  to   = aws_nat_gateway.natgw["3"]
}
moved {
  from = aws_nat_gateway.natgw[4]
  to   = aws_nat_gateway.natgw["4"]
}
moved {
  from = aws_nat_gateway.natgw[5]
  to   = aws_nat_gateway.natgw["5"]
}

# --- S3 endpoint route-table associations (public_s3 is count [0], not moved) ---
moved {
  from = aws_vpc_endpoint_route_table_association.private_s3[0]
  to   = aws_vpc_endpoint_route_table_association.private_s3["0"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.private_s3[1]
  to   = aws_vpc_endpoint_route_table_association.private_s3["1"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.private_s3[2]
  to   = aws_vpc_endpoint_route_table_association.private_s3["2"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.private_s3[3]
  to   = aws_vpc_endpoint_route_table_association.private_s3["3"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.private_s3[4]
  to   = aws_vpc_endpoint_route_table_association.private_s3["4"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.private_s3[5]
  to   = aws_vpc_endpoint_route_table_association.private_s3["5"]
}

moved {
  from = aws_vpc_endpoint_route_table_association.db_s3[0]
  to   = aws_vpc_endpoint_route_table_association.db_s3["0"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.db_s3[1]
  to   = aws_vpc_endpoint_route_table_association.db_s3["1"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.db_s3[2]
  to   = aws_vpc_endpoint_route_table_association.db_s3["2"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.db_s3[3]
  to   = aws_vpc_endpoint_route_table_association.db_s3["3"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.db_s3[4]
  to   = aws_vpc_endpoint_route_table_association.db_s3["4"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.db_s3[5]
  to   = aws_vpc_endpoint_route_table_association.db_s3["5"]
}

moved {
  from = aws_vpc_endpoint_route_table_association.dmz_s3[0]
  to   = aws_vpc_endpoint_route_table_association.dmz_s3["0"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.dmz_s3[1]
  to   = aws_vpc_endpoint_route_table_association.dmz_s3["1"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.dmz_s3[2]
  to   = aws_vpc_endpoint_route_table_association.dmz_s3["2"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.dmz_s3[3]
  to   = aws_vpc_endpoint_route_table_association.dmz_s3["3"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.dmz_s3[4]
  to   = aws_vpc_endpoint_route_table_association.dmz_s3["4"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.dmz_s3[5]
  to   = aws_vpc_endpoint_route_table_association.dmz_s3["5"]
}

moved {
  from = aws_vpc_endpoint_route_table_association.mgmt_s3[0]
  to   = aws_vpc_endpoint_route_table_association.mgmt_s3["0"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.mgmt_s3[1]
  to   = aws_vpc_endpoint_route_table_association.mgmt_s3["1"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.mgmt_s3[2]
  to   = aws_vpc_endpoint_route_table_association.mgmt_s3["2"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.mgmt_s3[3]
  to   = aws_vpc_endpoint_route_table_association.mgmt_s3["3"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.mgmt_s3[4]
  to   = aws_vpc_endpoint_route_table_association.mgmt_s3["4"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.mgmt_s3[5]
  to   = aws_vpc_endpoint_route_table_association.mgmt_s3["5"]
}

moved {
  from = aws_vpc_endpoint_route_table_association.workspaces_s3[0]
  to   = aws_vpc_endpoint_route_table_association.workspaces_s3["0"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.workspaces_s3[1]
  to   = aws_vpc_endpoint_route_table_association.workspaces_s3["1"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.workspaces_s3[2]
  to   = aws_vpc_endpoint_route_table_association.workspaces_s3["2"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.workspaces_s3[3]
  to   = aws_vpc_endpoint_route_table_association.workspaces_s3["3"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.workspaces_s3[4]
  to   = aws_vpc_endpoint_route_table_association.workspaces_s3["4"]
}
moved {
  from = aws_vpc_endpoint_route_table_association.workspaces_s3[5]
  to   = aws_vpc_endpoint_route_table_association.workspaces_s3["5"]
}

# --- Subnet route-table associations (no mgmt association resource exists) ---
moved {
  from = aws_route_table_association.private[0]
  to   = aws_route_table_association.private["0"]
}
moved {
  from = aws_route_table_association.private[1]
  to   = aws_route_table_association.private["1"]
}
moved {
  from = aws_route_table_association.private[2]
  to   = aws_route_table_association.private["2"]
}
moved {
  from = aws_route_table_association.private[3]
  to   = aws_route_table_association.private["3"]
}
moved {
  from = aws_route_table_association.private[4]
  to   = aws_route_table_association.private["4"]
}
moved {
  from = aws_route_table_association.private[5]
  to   = aws_route_table_association.private["5"]
}

moved {
  from = aws_route_table_association.public[0]
  to   = aws_route_table_association.public["0"]
}
moved {
  from = aws_route_table_association.public[1]
  to   = aws_route_table_association.public["1"]
}
moved {
  from = aws_route_table_association.public[2]
  to   = aws_route_table_association.public["2"]
}
moved {
  from = aws_route_table_association.public[3]
  to   = aws_route_table_association.public["3"]
}
moved {
  from = aws_route_table_association.public[4]
  to   = aws_route_table_association.public["4"]
}
moved {
  from = aws_route_table_association.public[5]
  to   = aws_route_table_association.public["5"]
}

moved {
  from = aws_route_table_association.db[0]
  to   = aws_route_table_association.db["0"]
}
moved {
  from = aws_route_table_association.db[1]
  to   = aws_route_table_association.db["1"]
}
moved {
  from = aws_route_table_association.db[2]
  to   = aws_route_table_association.db["2"]
}
moved {
  from = aws_route_table_association.db[3]
  to   = aws_route_table_association.db["3"]
}
moved {
  from = aws_route_table_association.db[4]
  to   = aws_route_table_association.db["4"]
}
moved {
  from = aws_route_table_association.db[5]
  to   = aws_route_table_association.db["5"]
}

moved {
  from = aws_route_table_association.dmz[0]
  to   = aws_route_table_association.dmz["0"]
}
moved {
  from = aws_route_table_association.dmz[1]
  to   = aws_route_table_association.dmz["1"]
}
moved {
  from = aws_route_table_association.dmz[2]
  to   = aws_route_table_association.dmz["2"]
}
moved {
  from = aws_route_table_association.dmz[3]
  to   = aws_route_table_association.dmz["3"]
}
moved {
  from = aws_route_table_association.dmz[4]
  to   = aws_route_table_association.dmz["4"]
}
moved {
  from = aws_route_table_association.dmz[5]
  to   = aws_route_table_association.dmz["5"]
}

moved {
  from = aws_route_table_association.workspaces[0]
  to   = aws_route_table_association.workspaces["0"]
}
moved {
  from = aws_route_table_association.workspaces[1]
  to   = aws_route_table_association.workspaces["1"]
}
moved {
  from = aws_route_table_association.workspaces[2]
  to   = aws_route_table_association.workspaces["2"]
}
moved {
  from = aws_route_table_association.workspaces[3]
  to   = aws_route_table_association.workspaces["3"]
}
moved {
  from = aws_route_table_association.workspaces[4]
  to   = aws_route_table_association.workspaces["4"]
}
moved {
  from = aws_route_table_association.workspaces[5]
  to   = aws_route_table_association.workspaces["5"]
}

