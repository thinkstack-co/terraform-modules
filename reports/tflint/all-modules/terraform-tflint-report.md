# TFLint Report

## Summary
❌ **Status**: FAILED - 15 TFLint issues found

## Issues Found

### Warning: data "aws_caller_identity" "current" is declared but not used

- **File**: `global/iam/iam_users/aws_iam_user.tf`
- **Line**: 1:1
- **Rule**: `terraform_unused_declarations`

### Warning: data "aws_caller_identity" "current" is declared but not used

- **File**: `global/iam/iam_roles/iam_role.tf`
- **Line**: 2:1
- **Rule**: `terraform_unused_declarations`

### Warning: data "aws_caller_identity" "current" is declared but not used

- **File**: `global/iam/iam_policies/s3_put_object/s3_put_object.tf`
- **Line**: 1:1
- **Rule**: `terraform_unused_declarations`

### Warning: data "aws_s3_bucket" "cost_report" is declared but not used

- **File**: `modules/aws/aws_cost_report/main.tf`
- **Line**: 175:1
- **Rule**: `terraform_unused_declarations`

### Warning: data "aws_s3_objects" "report_pdfs" is declared but not used

- **File**: `modules/aws/aws_cost_report/main.tf`
- **Line**: 182:1
- **Rule**: `terraform_unused_declarations`

### Warning: variable "tags" is declared but not used

- **File**: `modules/aws/nlb/nlb_listener_rule/variables.tf`
- **Line**: 27:1
- **Rule**: `terraform_unused_declarations`

### Warning: variable "iam_for_cloudwatch" is declared but not used

- **File**: `modules/aws/cloudwatch/log_destination/variables.tf`
- **Line**: 66:1
- **Rule**: `terraform_unused_declarations`

### Warning: data "aws_caller_identity" "current" is declared but not used

- **File**: `modules/aws/ec2_instance/main.tf`
- **Line**: 19:1
- **Rule**: `terraform_unused_declarations`

### Warning: variable "ebs_block_device" is declared but not used

- **File**: `modules/aws/vendor/silverpeak/variables.tf`
- **Line**: 29:1
- **Rule**: `terraform_unused_declarations`

### Warning: variable "ephemeral_block_device" is declared but not used

- **File**: `modules/aws/vendor/silverpeak/variables.tf`
- **Line**: 41:1
- **Rule**: `terraform_unused_declarations`

### Warning: data "aws_caller_identity" "current" is declared but not used

- **File**: `modules/aws/vendor/cato_sdwan/main.tf`
- **Line**: 15:1
- **Rule**: `terraform_unused_declarations`

### Warning: variable "kms_key_id" is declared but not used

- **File**: `modules/aws/rds/cluster/variables.tf`
- **Line**: 143:1
- **Rule**: `terraform_unused_declarations`

### Warning: variable "scaling_configuration" is declared but not used

- **File**: `modules/aws/rds/cluster/variables.tf`
- **Line**: 174:1
- **Rule**: `terraform_unused_declarations`

### Warning: data "aws_caller_identity" "current" is declared but not used

- **File**: `modules/thinkstack/aws_backup_custom/modules/aws_backup_plans/main.tf`
- **Line**: 73:1
- **Rule**: `terraform_unused_declarations`

### Warning: data "aws_region" "current" is declared but not used

- **File**: `modules/thinkstack/aws_backup_custom/modules/aws_backup_plans/main.tf`
- **Line**: 75:1
- **Rule**: `terraform_unused_declarations`

```
Failed to run in examples/cloudformation_test/basic; exit status 1
```

```
Failed to load configurations; examples/cloudformation_test/basic/main.tf:21,1-29: "cloudformation_test" module is not found; The module directory "modules/aws/cloudformation_test" does not exist or cannot be read.:
```

```
[31mError[0m: "cloudformation_test" module is not found
```

```
  on examples/cloudformation_test/basic/main.tf line 21, in module "cloudformation_test":
```

```
  21: [1;4mmodule "cloudformation_test"[0m {
```

```
The module directory "modules/aws/cloudformation_test" does not exist or cannot be read.
```
