variable "key_name_prefix" {
    description = "SSL key pair name prefix, used to generate unique keypair name for EC2 instance deployments"
}

variable "public_key" {
    description = "Public rsa key"
}
