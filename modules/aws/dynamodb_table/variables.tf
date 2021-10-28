variable "attribute" {
  type        = list
  description = " (Required) List of nested attribute definitions. Only required for hash_key and range_key attributes. Each attribute has two properties: name - (Required) The name of the attribute. type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data"
}

variable "global_secondary_index" {
  type        = map
  description = "(Optional) Describe a GSO for the table; subject to the normal limits on the number of GSIs, projected attributes, etc."
  default     = {}
}

variable "hash_key" {
  type        = string
  description = "(Required, Forces new resource) The attribute to use as the hash (partition) key. Must also be defined as an attribute, see below."
}

variable "local_secondary_index" {
  type        = maps
  description = "(Optional, Forces new resource) Describe an LSI on the table; these can only be allocated at creation so you cannot change this definition after you have created the resource."
  default     = {}
}

variable "name" {
  type        = string
  description = "(Required) The name of the table, this needs to be unique within a region."
}

variable "point_in_time_recovery" {
  type        = map
  description = "(Optional) Point-in-time recovery options."
  default = {
    enabled = false
  }
}

variable "range_key" {
  type        = string
  description = "(Optional, Forces new resource) The attribute to use as the range (sort) key. Must also be defined as an attribute, see below."
}

variable "read_capacity" {
  type        = string
  description = "(Required) The number of read units for this table"
}

variable "server_side_encryption" {
  type        = map
  description = "(Optional) Encrypt at rest options."
  default = {
    enabled = true
  }
}

variable "stream_enabled" {
  type        = string
  description = "(Optional) Indicates whether Streams are to be enabled (true) or disabled (false)."
}

variable "tags" {
  type        = map
  description = "(Optional) A map of tags to populate on the created table."
  default     = {}
}

variable "ttl" {
  type        = map
  description = "(Optional) Defines ttl, has two properties, and can only be specified once: enabled - (Required) Indicates whether ttl is enabled (true) or disabled (false). attribute_name - (Required) The name of the table attribute to store the TTL timestamp in."
  default     = {}
}

variable "write_capacity" {
  type        = string
  description = "(Required) The number of write units for this table"
}
