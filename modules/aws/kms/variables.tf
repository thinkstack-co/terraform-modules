variable "description" {
  description = "(Optional) The description of the key as viewed in AWS console."
  default     = ""
}

variable "deletion_window_in_days" {
  description = "(Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
  default     = 30
}

variable "enable_key_rotation" {
  description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
  default     = true
}

variable "key_usage" {
  type        = string
  description = "(Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
  default     = "ENCRYPT_DECRYPT"
}

variable "is_enabled" {
  type        = string
  description = "(Optional) Specifies whether the key is enabled. Defaults to true."
  default     = true
}

variable "name" {
  type        = string
  description = "(Optional) The display name of the alias. The name must start with the word 'alias' followed by a forward slash"
}

variable "policy" {
  type        = string
  description = "(Optional) A valid policy JSON document."
  default     = null
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the object."
  default = {
    terraform  = "true"
    created_by = "terraform"
  }
}
