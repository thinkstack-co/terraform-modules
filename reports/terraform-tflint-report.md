# TFLint Report

## Summary
❌ **Status**: FAILED - 27 TFLint issues found

## Issues Found

### Warning: data "aws_caller_identity" "current" is declared but not used

- **File**: `global/iam/iam_policies/ebs_backup/ebs_backup.tf`
- **Line**: 1:1
- **Rule**: `terraform_unused_declarations`

### Warning: data "aws_caller_identity" "current" is declared but not used

- **File**: `global/iam/iam_users/aws_iam_user.tf`
- **Line**: 1:1
- **Rule**: `terraform_unused_declarations`

### Warning: data "aws_caller_identity" "current" is declared but not used

- **File**: `global/iam/iam_policies/mfa_self_serv/mfa_enforcement_policy.tf`
- **Line**: 1:1
- **Rule**: `terraform_unused_declarations`

### Warning: variable "tags" is declared but not used

- **File**: `modules/aws/alb/alb_target_group/variables.tf`
- **Line**: 22:1
- **Rule**: `terraform_unused_declarations`

### Warning: data "aws_s3_bucket" "cost_report" is declared but not used

- **File**: `modules/aws/aws_cost_report/main.tf`
- **Line**: 175:1
- **Rule**: `terraform_unused_declarations`

### Warning: data "aws_s3_bucket_objects" "report_pdfs" is declared but not used

- **File**: `modules/aws/aws_cost_report/main.tf`
- **Line**: 182:1
- **Rule**: `terraform_unused_declarations`

### Warning: variable "iam_for_cloudwatch" is declared but not used

- **File**: `modules/aws/cloudwatch/log_destination/variables.tf`
- **Line**: 66:1
- **Rule**: `terraform_unused_declarations`

### Warning: data "aws_caller_identity" "current" is declared but not used

- **File**: `global/iam/iam_groups/iam_groups.tf`
- **Line**: 2:1
- **Rule**: `terraform_unused_declarations`

### Warning: Missing version constraint for provider "aws" in `required_providers`

- **File**: `modules/aws/s3/notification/main.tf`
- **Line**: 2:1
- **Rule**: `terraform_required_providers`

### Warning: terraform "required_version" attribute is required

- **File**: `modules/aws/s3/notification/main.tf`
- **Line**: 1:1
- **Rule**: `terraform_required_version`

### Warning: data "aws_caller_identity" "current" is declared but not used

- **File**: `global/iam/iam_policies/s3_put_object/s3_put_object.tf`
- **Line**: 1:1
- **Rule**: `terraform_unused_declarations`

### Warning: terraform "required_version" attribute is required

- **File**: `modules/terraform/oauth_client/main.tf`
- **Line**: 1:1
- **Rule**: `terraform_required_version`

### Warning: data "aws_caller_identity" "current" is declared but not used

- **File**: `modules/aws/vendor/cato_sdwan/main.tf`
- **Line**: 15:1
- **Rule**: `terraform_unused_declarations`

### Warning: terraform "required_version" attribute is required

- **File**: `modules/terraform/team/main.tf`
- **Line**: 1:1
- **Rule**: `terraform_required_version`

### Warning: terraform "required_version" attribute is required

- **File**: `modules/terraform/team_access/main.tf`
- **Line**: 1:1
- **Rule**: `terraform_required_version`

### Warning: terraform "required_version" attribute is required

- **File**: `modules/aws/network_diagram_generator/main.tf`
- **Line**: 1:1
- **Rule**: `terraform_required_version`

### Warning: variable "ephemeral_block_device" is declared but not used

- **File**: `modules/aws/vendor/silverpeak/variables.tf`
- **Line**: 41:1
- **Rule**: `terraform_unused_declarations`

### Warning: variable "ebs_block_device" is declared but not used

- **File**: `modules/aws/vendor/silverpeak/variables.tf`
- **Line**: 29:1
- **Rule**: `terraform_unused_declarations`

### Warning: variable "scaling_configuration" is declared but not used

- **File**: `modules/aws/rds/cluster/variables.tf`
- **Line**: 174:1
- **Rule**: `terraform_unused_declarations`

### Warning: variable "kms_key_id" is declared but not used

- **File**: `modules/aws/rds/cluster/variables.tf`
- **Line**: 143:1
- **Rule**: `terraform_unused_declarations`

### Warning: Lookup with 2 arguments is deprecated

- **File**: `modules/aws/elastic_beanstalk_environment/main.tf`
- **Line**: 28:19
- **Rule**: `terraform_deprecated_lookup`

### Warning: Lookup with 2 arguments is deprecated

- **File**: `modules/aws/elastic_beanstalk_environment/main.tf`
- **Line**: 29:19
- **Rule**: `terraform_deprecated_lookup`

### Warning: Lookup with 2 arguments is deprecated

- **File**: `modules/aws/elastic_beanstalk_environment/main.tf`
- **Line**: 30:19
- **Rule**: `terraform_deprecated_lookup`

### Warning: variable "tags" is declared but not used

- **File**: `modules/aws/nlb/nlb_listener_rule/variables.tf`
- **Line**: 27:1
- **Rule**: `terraform_unused_declarations`

### Warning: data "aws_caller_identity" "current" is declared but not used

- **File**: `modules/aws/ec2_instance/main.tf`
- **Line**: 19:1
- **Rule**: `terraform_unused_declarations`

### Warning: terraform "required_version" attribute is required

- **File**: `modules/module_template/main.tf`
- **Line**: 1:1
- **Rule**: `terraform_required_version`

### Warning: data "aws_caller_identity" "current" is declared but not used

- **File**: `global/iam/iam_roles/iam_role.tf`
- **Line**: 2:1
- **Rule**: `terraform_unused_declarations`

