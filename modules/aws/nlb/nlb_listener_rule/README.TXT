################## HOW TO USE AWS_LB_LISTENER_RULE ##################################################################

This guide will help you understand how to use variables with the `aws_lb_listener_rule` resource block in Terraform.

#################### VARIABLES #####################################################################################

Below are the variables used in the `aws_lb_listener_rule` resource block:

1. `listener_arn`: The ARN of the listener to which you want to attach the rule.

2. `priority`: The priority for the rule between 1 and 50000. If unset, the next available priority after the current highest rule will be used. A listener can't have multiple rules with the same priority.

3. `target_group_arn`: The ARN of the Target Group to which to route traffic.

4. `condition_field`: The name of the field. It must be 'path-pattern' for path-based routing or 'host-header' for host-based routing.

5. `condition_values`: The path patterns to match. A maximum of 1 can be defined.

################################ MODULE EXAMPLE ###################################################################
Here's an example usage of the variables:  Keep in mind, the references to other modules are based on the other
resources in this ALB Resource Group.  You will need to have modules set for a listener and a target group for
this module to be relevant.

module "listener_rule_example" {
  source = "example/modules/aws/nlb/nlb_listener_rule"

  listener_arn     = module.listener_1.listener_arn  <---- Use the nlb_listener resource to set this module
  priority         = 10
  target_group_arn = module.target_group_1.target_group_arn <------ Use the nlb_target_group resource to set this module
  condition_field  = "source-ip"
  condition_values = ["192.0.2.0/24"]
}

The effect of this NLB listener rule would be that any incoming traffic with a source IP address falling within
the range 192.0.2.0/24 (e.g., 192.0.2.1, 192.0.2.100, etc.) would be forwarded to the target group associated
with the NLB listener.

############### CONDITION FIELD AND VALUES ##############################################################################

The `condition_field` and `condition_values` variables are used to determine how to route requests that reach the listener.

The `condition_field` variable can be set to 'path-pattern' for path-based routing or 'host-header' for host-based routing.

The effect of this NLB listener rule would be that any incoming traffic with a source IP address falling within
the range 192.0.2.0/24 (e.g., 192.0.2.1, 192.0.2.100, etc.) would be forwarded to the target group associated
with the NLB listener.
