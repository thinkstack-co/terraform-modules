variable "kms_key_description" {
    description = "The description"
    default     = "KMS key for encrypting and decrypting resources"
}

variable "kms_key_deletion_window" {
    description = "How long before the key is deleted when resources are deleted"
    default     = 30
}
