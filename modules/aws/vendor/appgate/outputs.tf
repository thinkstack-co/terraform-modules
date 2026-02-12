output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "instance_name" {
  description = "Instance Name tag"
  value       = local.instance_name
}

output "public_ip" {
  description = "Elastic IP — Appgate appliance hostname"
  value       = aws_eip.this.public_ip
}

output "private_ip" {
  description = "Private IP of the gateway ENI"
  value       = aws_network_interface.this.private_ip
}

output "security_group_id" {
  description = "Appgate security group ID"
  value       = aws_security_group.this.id
}

output "network_interface_id" {
  description = "ENI ID"
  value       = aws_network_interface.this.id
}

output "elastic_ip_allocation_id" {
  description = "EIP allocation ID"
  value       = aws_eip.this.allocation_id
}

output "ami_id" {
  description = "AMI used"
  value       = aws_instance.this.ami
}

output "appgate_appliance_id" {
  description = "Appgate appliance ID (null if not managed)"
  value       = var.manage_appgate_appliance ? appgatesdp_appliance.this[0].id : null
}

output "it_glue_config" {
  description = "IT Glue configuration entry data"
  value = {
    name            = local.instance_name
    model           = "Amazon ${var.instance_type}"
    hostname        = local.instance_name
    default_gateway = cidrhost(data.aws_subnet.this.cidr_block, 1)
    os              = "Linux (Ubuntu - Appgate SDP)"
    private_ip      = aws_network_interface.this.private_ip
    public_ip       = aws_eip.this.public_ip
    storage         = "${var.root_volume_size} GiB gp3 encrypted"
  }
}
