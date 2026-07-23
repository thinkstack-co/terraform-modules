# TFLint configuration for terraform-modules.
# Enables Terraform core rules and AWS provider rules for better detection of
# deprecated syntax, invalid arguments, and provider-specific issues.

plugin "terraform" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
  version = "0.13.0"
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  version = "0.44.0"
}

# ─── Rule overrides for a module library ──────────────────────────────────
# This repo publishes reusable modules consumed by root-configurations in
# downstream customer repos. Several default tflint rules are sized for root
# modules and produce noise here:

# Why: variable declarations are part of a module's public API. Some are
# accepted today and not yet wired through the implementation, or are
# intentionally pass-through hooks for future work. Removing them is a
# breaking change for consumers passing those values.
rule "terraform_unused_declarations" {
  enabled = false
}

# Why: required_version belongs on root configurations that drive provider
# selection. Child modules inherit from the caller; pinning it here forces
# every consumer onto the same Terraform version regardless of context.
rule "terraform_required_version" {
  enabled = false
}

# You can optionally pin a default AWS region for rules that need it.
# If you manage multiple regions, leave this unset or override via .tflint.hcl in subdirs.
# aws_region = "us-east-1"
