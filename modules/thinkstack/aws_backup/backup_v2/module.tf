/*
module "aws_backup_ec2" {
  source = "path/to/aws_backup_ec2_module"

  key_bypass_policy_lockout_safety_check = true
  key_customer_master_key_spec           = "SYMMETRIC_DEFAULT"
  key_description                        = "Key for Custom EC2 backups"
  key_deletion_window_in_days            = 7
  key_enable_key_rotation                = true
  key_usage                              = "ENCRYPT_DECRYPT"
  key_is_enabled                         = true
  key_name                               = "alias/myBackupKey"
  backup_vault_name                      = "MyCustomVault"
  backup_plan_name                       = "MyEC2BackupPlan"
  backup_rule_name                       = "MyDailyBackup"
  schedule                               = "cron(0 20 * * ? *)"
  cold_storage_after_days                = 30
  delete_after_days                      = 90
  instance_ids                           = [module.aws_prod_exmaple.id, "i-0abcdef1234567890"]
  tags = {
    Environment = "production"
    Project     = "ProjectName"
  }
}
*/
