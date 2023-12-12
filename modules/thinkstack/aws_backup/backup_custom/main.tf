terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0.0"
      configuration_aliases = [aws.aws_prod_region, aws.aws_dr_region]
    }
  }
}

###############################################################
# KMS Encryption Key
###############################################################

# Production region key
# KMS Key for Production Region
resource "aws_kms_key" "prod_key" {
  provider                           = aws.aws_prod_region
  count                              = var.dr_region_key ? 0 : 1
  bypass_policy_lockout_safety_check = var.key_bypass_policy_lockout_safety_check
  customer_master_key_spec           = var.key_customer_master_key_spec
  description                        = var.key_description
  deletion_window_in_days            = var.key_deletion_window_in_days
  enable_key_rotation                = var.key_enable_key_rotation
  key_usage                          = var.key_usage
  is_enabled                         = var.key_is_enabled
  policy                             = var.key_policy
  tags                               = var.key_tags
}

# KMS Key for DR Region
resource "aws_kms_key" "dr_key" {
  provider                           = aws.aws_dr_region
  count                              = var.dr_region_key ? 1 : 0
  bypass_policy_lockout_safety_check = var.key_bypass_policy_lockout_safety_check
  customer_master_key_spec           = var.key_customer_master_key_spec
  description                        = var.key_description
  deletion_window_in_days            = var.key_deletion_window_in_days
  enable_key_rotation                = var.key_enable_key_rotation
  key_usage                          = var.key_usage
  is_enabled                         = var.key_is_enabled
  policy                             = var.key_policy
  tags                               = var.key_tags
}


resource "aws_kms_alias" "prod_kms_alias" {
  provider      = aws.aws_prod_region
  count         = var.dr_region_key ? 0 : 1
  name          = var.key_name
  target_key_id = aws_kms_key.key.key_id
}

resource "aws_kms_alias" "dr_kms_alias" {
  provider      = aws.aws_dr_region
  count         = var.dr_region_key ? 1 : 0
  name          = var.key_name
  target_key_id = aws_kms_key.key.key_id
}

###############################################################
# IAM
###############################################################
# Assume Role - Prod
resource "aws_iam_role" "aws_backup_role" {
  name               = "aws_backup_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

# Policy Attachment
resource "aws_iam_role_policy_attachment" "backup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.prod_backup.name
}

resource "aws_iam_role_policy_attachment" "restores" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.prod_backup.name
}


#####################
# BACKUP VAULTS
#####################

resource "aws_backup_vault" "backup_vault" {
  for_each = { for job in var.backup_jobs : job.selection_tag => job }

  provider    = each.value.dr_region ? aws.aws_dr_region : aws.aws_prod_region
  name        = each.value.vault_name
  kms_key_arn = each.value.dr_region ? aws_kms_key.dr_key[0].arn : aws_kms_key.prod_key[0].arn
  tags        = var.vault_tags
}


#######################
# BACKUP PLANS
#######################

resource "aws_backup_plan" "plan" {
  for_each = { for job in var.backup_jobs : job.selection_tag => job }
  
  provider = each.value.dr_region ? aws.aws_dr_region : aws.aws_prod_region
  name     = "${each.value.vault_name}_plan"
  tags     = var.plan_tags

  rule {
    rule_name         = each.value.rule_name
    target_vault_name = each.value.vault_name
    schedule          = each.value.schedule
    lifecycle {
      delete_after = each.value.retention_days
    }
  }
}

##########################
# BACKUP SELECTION
#########################

resource "aws_backup_selection" "backup_selection" {
  for_each = { for job in var.backup_jobs : job.selection_tag => job }
  
  provider     = each.value.dr_region ? aws.aws_dr_region : aws.aws_prod_region
  plan_id      = aws_backup_plan.plan[each.key].id
  name         = "${each.key}_selection"
  iam_role_arn = aws_iam_role.backup.arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup_tag"
    value = each.value.selection_tag
  }
}





