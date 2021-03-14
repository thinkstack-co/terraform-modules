output "lan_nic_id" {
    value = [aws_network_interface.lan0_nic.*.id]
}
