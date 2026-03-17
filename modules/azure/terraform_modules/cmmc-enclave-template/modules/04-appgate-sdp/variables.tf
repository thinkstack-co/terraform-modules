variable "resource_group_name" {
  description = "Name of the resource group to deploy into."
  type        = string
}

variable "location" {
  description = "Azure Government region. Appgate capacity is most reliable in usgovarizona."
  type        = string
  default     = "usgovarizona"
}

variable "tenant_id" {
  description = "Entra ID tenant ID (used for Key Vault access policies)."
  type        = string
}

variable "ztna_subnet_id" {
  description = "Resource ID of the ZTNA subnet (from 02-mgmt-vnet)."
  type        = string
}

variable "firewall_policy_id" {
  description = "Resource ID of the Azure Firewall Policy (from 02-mgmt-vnet) for adding DNAT rules."
  type        = string
}

variable "firewall_public_ip" {
  description = "Primary public IP of the Azure Firewall for DNAT destination."
  type        = string
}

variable "source_admin_ips" {
  description = "List of IP addresses/CIDRs permitted to SSH to Appgate Controller and Gateway."
  type        = list(string)
}

variable "controller_vm_size" {
  description = "VM size for the Appgate SDP combined appliance (controller + gateway)."
  type        = string
  default     = "Standard_B2s"
}

variable "deploy_vms" {
  description = "Deploy Appgate combined VM. Set false until marketplace plan access is confirmed for the subscription."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
