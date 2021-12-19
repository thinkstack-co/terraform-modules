Flow Logs Module
=================

This module sets up each componenet required to capture ENI Flow Logs with the parameters specified. By default this module will be set up to work without any changes to variables. The result of this module creates a unique cloudwatch log group with a prefix of 'flow_logs', an IAM policy and IAM role which can be used with ENI flow logs to deliver logs to that cloudwatch log group.


# Usage

    module "flow_logs" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/flow_logs"

        flow_vpc_id = "vpc-42718oh421"
    }

# Variables
    key_customer_master_key_spec
    key_description
    key_deletion_window_in_days
    key_enable_key_rotation
    key_usage
    key_is_enabled
    key_name_prefix
    cloudwatch_name_prefix
    cloudwatch_retention_in_days
    iam_policy_description
    iam_policy_name_prefix
    iam_policy_path
    iam_role_assume_role_policy
    iam_role_description
    iam_role_force_detach_policies
    iam_role_max_session_duration
    iam_role_name_prefix
    iam_role_permissions_boundary
    flow_log_destination_type
    flow_max_aggregation_interval
    flow_traffic_type
    flow_vpc_id
    tags
## Required
    flow_vpc_id

## Optional
    key_bypass_policy_lockout_safety_check
    key_customer_master_key_spec
    key_description
    key_deletion_window_in_days
    key_enable_key_rotation
    key_usage
    key_is_enabled
    key_name_prefix
    cloudwatch_name_prefix
    cloudwatch_retention_in_days
    iam_policy_description
    iam_policy_name_prefix
    iam_policy_path
    iam_role_assume_role_policy
    iam_role_description
    iam_role_force_detach_policies
    iam_role_max_session_duration
    iam_role_name_prefix
    iam_role_permissions_boundary
    flow_log_destination_type
    flow_max_aggregation_interval
    flow_traffic_type
    tags
# Outputs
    arn
