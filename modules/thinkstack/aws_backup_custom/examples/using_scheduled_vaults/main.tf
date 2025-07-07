terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# DR region provider (optional)
provider "aws" {
  alias  = "dr"
  region = var.dr_region
}

# KMS Key for encryption in primary region
resource "aws_kms_key" "backup" {
  description             = "KMS key for AWS Backup encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  tags = var.tags
}

resource "aws_kms_alias" "backup" {
  name          = "alias/${var.project_name}-backup-encryption"
  target_key_id = aws_kms_key.backup.key_id
}

# KMS Key for encryption in DR region
resource "aws_kms_key" "dr_backup" {
  count                   = var.enable_dr ? 1 : 0
  provider                = aws.dr
  description             = "DR region KMS key for AWS Backup encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  tags = merge(var.tags, { Type = "DR" })
}

resource "aws_kms_alias" "dr_backup" {
  count         = var.enable_dr ? 1 : 0
  provider      = aws.dr
  name          = "alias/${var.project_name}-dr-backup-encryption"
  target_key_id = aws_kms_key.dr_backup[0].key_id
}

# Create IAM role for AWS Backup
module "backup_iam_role" {
  source = "../../modules/aws_backup_iam_role"

  role_name                  = "${var.project_name}-backup-role"
  enable_tag_based_selection = true
  
  tags = var.tags
}

# Create backup vaults using the new scheduled vault feature
module "backup_vaults" {
  source = "../../modules/aws_backup_vault"
  
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  create_single_vault = false
  vault_name_prefix   = var.project_name
  
  # Enable desired vaults
  enable_hourly_vault  = var.enable_hourly_vault
  enable_daily_vault   = var.enable_daily_vault
  enable_weekly_vault  = var.enable_weekly_vault
  enable_monthly_vault = var.enable_monthly_vault
  enable_yearly_vault  = var.enable_yearly_vault
  
  # DR configuration
  enable_dr            = var.enable_dr
  dr_vault_name_prefix = "${var.project_name}-dr"
  dr_kms_key_arn       = var.enable_dr ? aws_kms_key.dr_backup[0].arn : null
  
  # Selective DR vault creation (all default to true)
  enable_hourly_dr_vault  = var.enable_hourly_dr
  enable_daily_dr_vault   = var.enable_daily_dr
  enable_weekly_dr_vault  = var.enable_weekly_dr
  enable_monthly_dr_vault = var.enable_monthly_dr
  enable_yearly_dr_vault  = var.enable_yearly_dr
  
  # Vault configuration
  kms_key_arn       = aws_kms_key.backup.arn
  enable_vault_lock = var.enable_vault_lock
  
  tags = var.tags
}

# Create backup plans for each enabled vault
module "hourly_backup_plan" {
  count  = var.enable_hourly_vault ? 1 : 0
  source = "../../modules/aws_backup_plans"

  name = "${var.project_name}-hourly-plan"
  
  rules = [
    {
      rule_name         = "hourly-backup-rule"
      target_vault_name = module.backup_vaults.scheduled_vault_names["hourly"]
      schedule          = "cron(0 * * * ? *)" # Every hour
      start_window      = 60
      completion_window = 1440
      
      lifecycle = {
        delete_after = 1
      }
      
      # Add DR copy if enabled
      copy_actions = var.enable_dr ? [
        {
          destination_vault_arn = module.backup_vaults.dr_vault_arns["hourly"]
          lifecycle = {
            delete_after = 3
          }
        }
      ] : []
    }
  ]
  
  # Windows VSS support
  advanced_backup_settings = var.enable_windows_vss ? [
    {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  ] : []
  
  tags = var.tags
}

module "daily_backup_plan" {
  count  = var.enable_daily_vault ? 1 : 0
  source = "../../modules/aws_backup_plans"

  name = "${var.project_name}-daily-plan"
  
  rules = [
    {
      rule_name         = "daily-backup-rule"
      target_vault_name = module.backup_vaults.scheduled_vault_names["daily"]
      schedule          = "cron(0 1 * * ? *)" # Daily at 1 AM
      start_window      = 60
      completion_window = 1440
      
      lifecycle = {
        delete_after = 7
      }
      
      copy_actions = var.enable_dr ? [
        {
          destination_vault_arn = module.backup_vaults.dr_vault_arns["daily"]
          lifecycle = {
            delete_after = 14
          }
        }
      ] : []
    }
  ]
  
  advanced_backup_settings = var.enable_windows_vss ? [
    {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  ] : []
  
  tags = var.tags
}

module "weekly_backup_plan" {
  count  = var.enable_weekly_vault ? 1 : 0
  source = "../../modules/aws_backup_plans"

  name = "${var.project_name}-weekly-plan"
  
  rules = [
    {
      rule_name         = "weekly-backup-rule"
      target_vault_name = module.backup_vaults.scheduled_vault_names["weekly"]
      schedule          = "cron(0 1 ? * SUN *)" # Weekly on Sunday at 1 AM
      start_window      = 60
      completion_window = 1440
      
      lifecycle = {
        delete_after = 30
      }
      
      copy_actions = var.enable_dr ? [
        {
          destination_vault_arn = module.backup_vaults.dr_vault_arns["weekly"]
          lifecycle = {
            delete_after = 60
          }
        }
      ] : []
    }
  ]
  
  tags = var.tags
}

module "monthly_backup_plan" {
  count  = var.enable_monthly_vault ? 1 : 0
  source = "../../modules/aws_backup_plans"

  name = "${var.project_name}-monthly-plan"
  
  rules = [
    {
      rule_name         = "monthly-backup-rule"
      target_vault_name = module.backup_vaults.scheduled_vault_names["monthly"]
      schedule          = "cron(0 1 1 * ? *)" # Monthly on the 1st at 1 AM
      start_window      = 60
      completion_window = 1440
      
      lifecycle = {
        delete_after = 365
      }
      
      copy_actions = var.enable_dr ? [
        {
          destination_vault_arn = module.backup_vaults.dr_vault_arns["monthly"]
          lifecycle = {
            delete_after = 730 # 2 years
          }
        }
      ] : []
    }
  ]
  
  tags = var.tags
}

module "yearly_backup_plan" {
  count  = var.enable_yearly_vault ? 1 : 0
  source = "../../modules/aws_backup_plans"

  name = "${var.project_name}-yearly-plan"
  
  rules = [
    {
      rule_name         = "yearly-backup-rule"
      target_vault_name = module.backup_vaults.scheduled_vault_names["yearly"]
      schedule          = "cron(0 1 1 1 ? *)" # Yearly on January 1st at 1 AM
      start_window      = 60
      completion_window = 1440
      
      lifecycle = {
        delete_after = 2555 # 7 years
      }
      
      copy_actions = var.enable_dr ? [
        {
          destination_vault_arn = module.backup_vaults.dr_vault_arns["yearly"]
          lifecycle = {
            delete_after = 2555 # 7 years
          }
        }
      ] : []
    }
  ]
  
  tags = var.tags
}

# Create backup selections
module "hourly_backup_selection" {
  count  = var.enable_hourly_vault ? 1 : 0
  source = "../../modules/aws_backup_selection"

  name         = "${var.project_name}-hourly-selection"
  iam_role_arn = module.backup_iam_role.role_arn
  plan_id      = module.hourly_backup_plan[0].id
  
  selection_tags = [
    {
      type  = "STRINGEQUALS"
      key   = var.backup_tag_key
      value = "hourly"
    }
  ]
}

module "daily_backup_selection" {
  count  = var.enable_daily_vault ? 1 : 0
  source = "../../modules/aws_backup_selection"

  name         = "${var.project_name}-daily-selection"
  iam_role_arn = module.backup_iam_role.role_arn
  plan_id      = module.daily_backup_plan[0].id
  
  selection_tags = [
    {
      type  = "STRINGEQUALS"
      key   = var.backup_tag_key
      value = "daily"
    }
  ]
}

module "weekly_backup_selection" {
  count  = var.enable_weekly_vault ? 1 : 0
  source = "../../modules/aws_backup_selection"

  name         = "${var.project_name}-weekly-selection"
  iam_role_arn = module.backup_iam_role.role_arn
  plan_id      = module.weekly_backup_plan[0].id
  
  selection_tags = [
    {
      type  = "STRINGEQUALS"
      key   = var.backup_tag_key
      value = "weekly"
    }
  ]
}

module "monthly_backup_selection" {
  count  = var.enable_monthly_vault ? 1 : 0
  source = "../../modules/aws_backup_selection"

  name         = "${var.project_name}-monthly-selection"
  iam_role_arn = module.backup_iam_role.role_arn
  plan_id      = module.monthly_backup_plan[0].id
  
  selection_tags = [
    {
      type  = "STRINGEQUALS"
      key   = var.backup_tag_key
      value = "monthly"
    }
  ]
}

module "yearly_backup_selection" {
  count  = var.enable_yearly_vault ? 1 : 0
  source = "../../modules/aws_backup_selection"

  name         = "${var.project_name}-yearly-selection"
  iam_role_arn = module.backup_iam_role.role_arn
  plan_id      = module.yearly_backup_plan[0].id
  
  selection_tags = [
    {
      type  = "STRINGEQUALS"
      key   = var.backup_tag_key
      value = "yearly"
    }
  ]
}

# Example: Selection for resources that need multiple backup schedules
module "critical_resources_selection" {
  count  = var.enable_daily_vault && var.enable_weekly_vault ? 1 : 0
  source = "../../modules/aws_backup_selection"

  name         = "${var.project_name}-critical-daily"
  iam_role_arn = module.backup_iam_role.role_arn
  plan_id      = module.daily_backup_plan[0].id
  
  conditions = [
    {
      string_equals = [
        {
          key   = "aws:ResourceTag/Environment"
          value = "production"
        },
        {
          key   = "aws:ResourceTag/Critical"
          value = "true"
        }
      ]
    }
  ]
}

module "critical_resources_weekly_selection" {
  count  = var.enable_daily_vault && var.enable_weekly_vault ? 1 : 0
  source = "../../modules/aws_backup_selection"

  name         = "${var.project_name}-critical-weekly"
  iam_role_arn = module.backup_iam_role.role_arn
  plan_id      = module.weekly_backup_plan[0].id
  
  conditions = [
    {
      string_equals = [
        {
          key   = "aws:ResourceTag/Environment"
          value = "production"
        },
        {
          key   = "aws:ResourceTag/Critical"
          value = "true"
        }
      ]
    }
  ]
}