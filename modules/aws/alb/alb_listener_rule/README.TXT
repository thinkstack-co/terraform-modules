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
  source = "example/modules/aws/alb/alb_listener_rule"

  listener_arn     = module.listener_1.listener_arn  <---- Use the alb_listener resource to set this module
  priority         = 10
  target_group_arn = module.target_group_1.target_group_arn <------ Use the alb_target_group resource to set this module
  condition_field  = "path-pattern"
  condition_values = ["/images/*"]
}

############### CONDITION FIELD AND VALUES ##############################################################################

The `condition_field` and `condition_values` variables are used to determine how to route requests that reach the listener.

The `condition_field` variable can be set to 'path-pattern' for path-based routing or 'host-header' for host-based routing.

- Path-based routing (`path-pattern`) is used to route requests based on the URL path of the request. 
  For example, you could route all requests that contain '/images' in the URL to a specific target group.

- Host-based routing (`host-header`) is used to route requests based on the host header in the HTTP(S) header. 
  This is useful when you want to route traffic to different services based on the domain in the request.

The `condition_values` variable is a list that contains the values to match against. 
For path-pattern, this would be the paths to match, and for host-header, this would be the hosts to match.

************************************************************************************************************
################### EXAMPLES ############################################################################### 
************************************************************************************************************

Here are a few examples of how to use `condition_field` and `condition_values`:

#### PATH-BASED ROUTING MODULE #############################################################################
In this example, all requests with '/images' in the URL path will be routed according to this rule.

module "listener_rule" {
  // ... other variables

  condition_field  = "path-pattern"
  condition_values = ["/images/*"]
}

#### HOST-BASED ROUTING MODULE #############################################################################
In this example, all requests with 'example.com' as the host header will be routed according to this rule.

module "listener_rule" {
  // ... other variables

  condition_field  = "host-header"
  condition_values = ["example.com"]
}
