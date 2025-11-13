# TFLint configuration for terraform-modules
# Enables Terraform core rules and AWS provider rules for better detection of
# deprecated syntax, invalid arguments, and provider-specific issues.

plugin "terraform" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
  version = "0.13.0"
}

plugin "aws" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  version = "0.44.0"
}

# You can optionally pin a default AWS region for rules that need it.
# If you manage multiple regions, leave this unset or override via .tflint.hcl in subdirs.
# aws_region = "us-east-1"

# Example of enabling/deconfiguring individual rules as needed.
# rule "terraform_deprecated_*" { enabled = true }
# rule "terraform_required_version" { enabled = true }
