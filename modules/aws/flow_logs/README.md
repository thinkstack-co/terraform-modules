Flow Logs Module
=================

This module sets up each componenet required to capture ENI Flow Logs with the parameters specified. By default this module will be set up to work without any changes to variables. The result of this module creates a unique cloudwatch log group with a prefix of 'flow_logs', an IAM policy and IAM role which can be used with ENI flow logs to deliver logs to that cloudwatch log group.


# Usage

    module "flow_logs" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/flow_logs"

        aws_region = var.aws_region
    }

# Variables
    key_bypass_policy_lockout_safety_check
    key_customer_master_key_spec
    key_description
    key_deletion_window_in_days
    key_enable_key_rotation
    key_usage
    key_is_enabled
    key_name
    cloudwatch_name_prefix
    cloudwatch_retention_in_days
    iam_policy_description
    iam_policy_name
    iam_policy_path
    iam_role_assume_role_policy
    iam_role_description
    iam_role_force_detach_policies
    iam_role_max_session_duration
    iam_role_name
    iam_role_permissions_boundary
    aws_region
    tags
## Required
    aws_region

## Optional
    key_bypass_policy_lockout_safety_check
    key_customer_master_key_spec
    key_description
    key_deletion_window_in_days
    key_enable_key_rotation
    key_usage
    key_is_enabled
    key_name
    cloudwatch_name_prefix
    cloudwatch_retention_in_days
    iam_policy_description
    iam_policy_name
    iam_policy_path
    iam_role_assume_role_policy
    iam_role_description
    iam_role_force_detach_policies
    iam_role_max_session_duration
    iam_role_name
    iam_role_permissions_boundary
    tags
# Outputs
    arn
