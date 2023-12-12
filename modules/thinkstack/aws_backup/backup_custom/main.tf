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
  count = length([for job in var.backup_jobs : job if !job.dr_region])

  provider      = aws.aws_prod_region
  name          = var.key_name
  target_key_id = aws_kms_key.prod_key[count.index].key_id
}

resource "aws_kms_alias" "dr_kms_alias" {
  count = length([for job in var.backup_jobs : job if job.dr_region])

  provider      = aws.aws_dr_region
  name          = var.key_name
  target_key_id = aws_kms_key.dr_key[count.index].key_id
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
  role       = aws_iam_role.aws_backup_role.name
}

resource "aws_iam_role_policy_attachment" "restores" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.aws_backup_role.name
}


#####################
# BACKUP VAULTS
#####################

resource "aws_backup_vault" "prod_vault" {
  count = length([for job in var.backup_jobs : job if !job.dr_region])

  provider    = aws.aws_prod_region
  name        = var.backup_jobs[count.index].vault_name
  kms_key_arn = aws_kms_key.prod_key[0].arn
  tags        = var.backup_jobs[count.index].vault_tags
}

resource "aws_backup_vault" "dr_vault" {
  count = length([for job in var.backup_jobs : job if job.dr_region])

  provider    = aws.aws_dr_region
  name        = var.backup_jobs[count.index].vault_name
  kms_key_arn = aws_kms_key.dr_key[0].arn
  tags        = var.backup_jobs[count.index].vault_tags
}

#######################
# BACKUP PLANS
#######################

resource "aws_backup_plan" "prod_plan" {
  count = length([for job in var.backup_jobs : job if !job.dr_region])

  provider = aws.aws_prod_region
  name     = "${var.backup_jobs[count.index].vault_name}_plan"
  tags     = var.plan_tags

  rule {
    rule_name         = var.backup_jobs[count.index].rule_name
    target_vault_name = var.backup_jobs[count.index].vault_name
    schedule          = var.backup_jobs[count.index].schedule
    lifecycle {
      delete_after = var.backup_jobs[count.index].retention_days
    }
  }
}

resource "aws_backup_plan" "dr_plan" {
  count = length([for job in var.backup_jobs : job if job.dr_region])

  provider = aws.aws_dr_region
  name     = "${var.backup_jobs[count.index].vault_name}_plan"
  tags     = var.plan_tags

  rule {
    rule_name         = var.backup_jobs[count.index].rule_name
    target_vault_name = var.backup_jobs[count.index].vault_name
    schedule          = var.backup_jobs[count.index].schedule
    lifecycle {
      delete_after = var.backup_jobs[count.index].retention_days
    }
  }
}

##########################
# BACKUP SELECTION
#########################

resource "aws_backup_selection" "prod_backup_selection" {
  count = length([for job in var.backup_jobs : job if !job.dr_region])

  provider     = aws.aws_prod_region
  plan_id      = aws_backup_plan.prod_plan[count.index].id
  name         = "${var.backup_jobs[count.index].selection_tag}_selection"
  iam_role_arn = aws_iam_role.aws_backup_role.arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup_tag"
    value = var.backup_jobs[count.index].selection_tag
  }
}

resource "aws_backup_selection" "dr_backup_selection" {
  count = length([for job in var.backup_jobs : job if job.dr_region])

  provider     = aws.aws_dr_region
  plan_id      = aws_backup_plan.dr_plan[count.index].id
  name         = "${var.backup_jobs[count.index].selection_tag}_selection"
  iam_role_arn = aws_iam_role.aws_backup_role.arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup_tag"
    value = var.backup_jobs[count.index].selection_tag
  }
}



