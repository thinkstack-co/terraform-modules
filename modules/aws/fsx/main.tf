###########################
# FSx Instance
###########################

resource "aws_fsx_windows_file_system" "fsx" {
  kms_key_id                        = aws_kms_key.key.key_id
  storage_capacity                  = var.storage_capacity
  subnet_ids                        = var.subnet_ids
  throughput_capacity               = var.throughput_capacity
  backup_id                         = var.backup_id
  active_directory_id               = var.active_directory_id
  aliases                           = var.aliases
  automatic_backup_retention_days   = var.automatic_backup_retention_days
  copy_tags_to_backups              = var.copy_tags_to_backups
  daily_automatic_backup_start_time = var.daily_automatic_backup_start_time
  #replace below var with sg module in this code.
  security_group_ids                = var.security_group_ids
  skip_final_backup                 = var.skip_final_backup
  tags                              = var.tags
  weekly_maintenance_start_time     = var.weekly_maintenance_start_time
  deployment_type                   = var.deployment_type
  preferred_subnet_id               = var.preferred_subnet_id
  audit_log_configuration {
    audit_log_destination             = aws_cloudwatch_log_group.log_group[0]
    file_access_audit_log_level       = var.file_access_audit_log_level
    file_share_access_audit_log_level = var.file_access_audit_log_level
  }
  storage_type = var.storage_type
  # Active Directory Settings
  self_managed_active_directory {
    dns_ips                                = var.dns_ips
    domain_name                            = var.domain_name
    password                               = var.password #should be stored in TF cloud workspace
    username                               = var.username #should be stored in TF cloud workspace
    file_system_administrators_group       = var.file_system_administrators_group
    organizational_unit_distinguished_name = var.organizational_unit_distinguished_name
  }
}

###########################
# KMS Key
###########################
resource "aws_kms_key" "key" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  key_usage               = var.key_usage
  is_enabled              = var.is_enabled
  policy                  = var.policy
  tags                    = var.tags
}

resource "aws_kms_alias" "alias" {
  name          = var.name
  target_key_id = aws_kms_key.key.key_id
}

###########################
# CloudWatch Log Group
###########################

resource "aws_cloudwatch_log_group" "log_group" {
  count             = (var.enable_audit_logs == true ? 1 : 0)
  kms_key_id        = aws_kms_key.key.arn
  name_prefix       = var.cloudwatch_name_prefix
  retention_in_days = var.cloudwatch_retention_in_days
  tags              = var.tags
}

# ###########################
# # IAM Policy
# ###########################
# resource "aws_iam_policy" "policy" {
#   count       = (var.enable_audit_logs == true ? 1 : 0)
#   description = var.iam_policy_description
#   name_prefix = var.iam_policy_name_prefix
#   path        = var.iam_policy_path
#   tags        = var.tags
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Action = [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents",
#         "logs:DescribeLogGroups",
#         "logs:DescribeLogStreams"
#       ],
#       Resource = [
#         "${aws_cloudwatch_log_group.log_group[0].arn}:*"
#       ]
#     }]
#   })
# }

# ###########################
# # IAM Role
# ###########################

# resource "aws_iam_role" "role" {
#   count                 = (var.enable_audit_logs == true ? 1 : 0)
#   assume_role_policy    = var.iam_role_assume_role_policy
#   description           = var.iam_role_description
#   force_detach_policies = var.iam_role_force_detach_policies
#   max_session_duration  = var.iam_role_max_session_duration
#   name_prefix           = var.iam_role_name_prefix
#   permissions_boundary  = var.iam_role_permissions_boundary
# }

# resource "aws_iam_role_policy_attachment" "role_attach" {
#   count      = (var.enable_audit_logs == true ? 1 : 0)
#   role       = aws_iam_role.role[0].name
#   policy_arn = aws_iam_policy.policy[0].arn
# }

