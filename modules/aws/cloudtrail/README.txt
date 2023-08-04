module "cloudtrail_config" {
  source = "example/modules/aws/cloudtrail/cloudtrail_config"
  
  ######
  # KMS
  ######
  key_description                 = "A KMS key for CloudTrail"
  key_enable_key_rotation         = true
  key_customer_master_key_spec    = "SYMMETRIC_DEFAULT"
  key_deletion_window_in_days     = 7
  key_usage                       = "ENCRYPT_DECRYPT"
  key_is_enabled                  = true
  key_alias_name_prefix           = "alias/"
  key_tags                        = {
  "Environment" = "Production"
  "Application" = "CloudTrail"
}
  
  ##################
  # CLOUDTRAIL LOGS
  ##################
  log_group_name                  = "cloudtrail-log-group"
  log_group_retention_in_days     = 14
  
  #############
  # IAM POLICY
  #############
  iam_policy_description          = "CloudTrail IAM Policy"
  iam_policy_name                 = "CloudTrail-Policy"
  iam_policy_path                 = "/"
  
  ###########
  # IAM ROLE
  ###########
  iam_role_description            = "IAM Role for CloudTrail"
  iam_role_max_session_duration   = 3600
  iam_role_name                   = "CloudTrail-Role"
  iam_role_permissions_boundary   = null
  iam_role_force_detach_policies  = false
  
  ############
  # CLOUDTRAIL
  ############
  cloudtrail_name                          = "cloudtrail"
  cloudtrail_s3_key_prefix                 = "aws-logs"
  cloudtrail_include_global_service_events = true
  cloudtrail_is_multi_region_trail         = true
  cloudtrail_enable_log_file_validation    = true
  encrypt_logs                             = true
  
  #####
  # S3
  #####
  s3_bucket_prefix                = "cloudtrail-bucket"
  s3_force_destroy                = false
  versioning_enabled              = false
  mfa_delete_enabled              = false
  lifecycle_rule_enabled          = false
  transition_days_standard_ia                     = 30
  transition_days_glacier                         = 60
  noncurrent_version_transition_days_standard_ia  = 30
  noncurrent_version_transition_days_glacier      = 60
  expiration_days                                 = 365
  noncurrent_version_expiration_days              = 365
}
