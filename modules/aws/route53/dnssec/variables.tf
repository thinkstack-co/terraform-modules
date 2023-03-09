variable "customer_master_key_spec" {
  type        = string
  description = "(Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, HMAC_256, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide."
  default     = "ECC_NIST_P256"
  validation {
    condition     = contains(["SYMMETRIC_DEFAULT", "RSA_2048", "RSA_3072", "RSA_4096", "HMAC_256", "ECC_NIST_P256", "ECC_NIST_P384", "ECC_NIST_P521", "ECC_SECG_P256K1"], var.customer_master_key_spec)
    error_message = "The value must be one of SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, HMAC_256, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1."
  }
}

variable "deletion_window_in_days" {
  type        = number
  description = "(Optional) The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between 7 and 30, inclusive. If you do not specify a value, it defaults to 30. If the KMS key is a multi-Region primary key with replicas, the waiting period begins when the last of its replica keys is deleted. Otherwise, the waiting period begins immediately."
  default     = 7
}

variable "description" {
  type        = string
  description = "(Optional) The description of the key as viewed in AWS console."
  default     = "KMS key used in Route53 zone DNSSEC"
}

variable "enable_key_rotation" {
  type        = bool
  description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
  default     = false
}

variable "key_usage" {
  type        = string
  description = "(Optional) Specifies the intended use of the key. Valid values: ENCRYPT_DECRYPT, SIGN_VERIFY, or GENERATE_VERIFY_MAC. Defaults to ENCRYPT_DECRYPT."
  default     = "SIGN_VERIFY"
  validation {
    condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY", "GENERATE_VERIFY_MAC"], var.key_usage)
    error_message = "The value must be one of ENCRYPT_DECRYPT, SIGN_VERIFY, or GENERATE_VERIFY_MAC."
  }
}

variable "is_enabled" {
  type        = bool
  description = "(Optional) Specifies whether the key is enabled. Defaults to true."
  default     = true
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A map of tags to assign to the object. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default = {
    terraform = "true"
  }
}

variable "name_prefix" {
  description = "(Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/)."
  default     = "alias/dnssec_"
  type        = string
}

variable "hosted_zone_id" {
  type        = string
  description = "(Required) Identifier of the Route 53 Hosted Zone."
}

variable "name" {
  type        = string
  description = "(Required) Name of the key-signing key (KSK). Must be unique for each key-singing key in the same hosted zone."
}

variable "status" {
  type        = string
  description = "(Optional) Status of the key-signing key (KSK). Valid values: ACTIVE, INACTIVE. Defaults to ACTIVE."
  default     = "ACTIVE"
  validation {
    condition     = contains(["ACTIVE", "INACTIVE"], var.status)
    error_message = "The value must be one of ACTIVE or INACTIVE."
  }
}

variable "signing_status" {
  type        = string
  description = "(Optional) Hosted Zone signing status. Valid values: SIGNING, NOT_SIGNING. Defaults to SIGNING."
  default     = "SIGNING"
  validation {
    condition     = contains(["SIGNING", "NOT_SIGNING"], var.signing_status)
    error_message = "The value must be one of SIGNING or NOT_SIGNING."
  }
}