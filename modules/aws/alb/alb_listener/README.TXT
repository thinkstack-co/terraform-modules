################## HOW TO USE THE AWS_LB_LISTENER RESOURCE #########################################################

This guide will help you understand how to use variables with the `aws_lb_listener` resource block in Terraform.

#################### VARIABLES #####################################################################################

Below are the variables used in the `aws_lb_listener` resource block:

1. `alb_arn`: The ARN (Amazon Resource Name) of the Application Load Balancer.

2. `port`: The port on which the load balancer is listening.

3. `protocol`: The protocol for connections from clients to the load balancer. 
    Valid values are `HTTP`, `HTTPS`, `TCP`, `TLS`, `UDP`, `TCP_UDP`, `GENEVE`.

4. `ssl_policy`: The name of the SSL Policy for the listener. Required if `protocol` is set to `HTTPS` or `TLS`.

5. `ssl_certificate`: The ARN of the default SSL server certificate.

6. `target_groups`: A list of maps defining target group ARNs and their corresponding weights for load balancing.

7. `stickiness_enabled`: Boolean to enable / disable stickiness.

8. `stickiness_duration`: The time period, in seconds, during which requests from a client should be 
    routed to the same target. After this time period expires, the load balancer selects a new target.

################################ MODULE EXAMPLE ###################################################################
Here's an example usage of the variables:  Keep in mind, the references to other modules are based on the other 
resources in this ALB Resource Group.  You will need to have modules set for an Application Load Balancer and  
target group(s) for this module to be relevant.  The SSL cert can also be found under the ALB Resource Group.

#####################
SINGLE TARGET GROUP 
#####################
module "aws_prod_alb_listener" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_listener?ref=dev_alb"

  load_balancer_arn = module.aws_prod_alb.lb_arn           
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  ssl_certificate = module.aws_prod_ssl_certificate.acm_certificate_arn
  target_group_arn = module.aws-prod-target-group1.target_group_arn
  stickiness_enabled = false
    
  tags = {
    terraform   = "yes"
    created_by  = "Wesley Bey"
    environment = "prod"
    role        = "prod"
  }
}
#########################
MULTIPLE TARGET GROUPS 
#########################
module "aws_prod_alb_listener" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_listener?ref=dev_alb"

  load_balancer_arn = module.aws_prod_alb.lb_arn           
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  ssl_certificate = module.aws_prod_ssl_certificate.acm_certificate_arn
  target_groups = [
    {
      arn = module.aws_prod_alb_target_group_1.target_group_arn  
      weight = 100
    }
    {
      arn = module.aws_prod_alb_target_group_2.target_group_arn  
      weight = 50
    }
  ]
  stickiness_enabled = false
    
  tags = {
    terraform   = "yes"
    created_by  = "Wesley Bey"
    environment = "prod"
    role        = "prod"
  }
}


############################ Target Groups and Load Balancer Listener Rules #####################################

In the AWS Elastic Load Balancer (ELB) ecosystem, Target Groups are used to route requests to one or more registered 
targets (like EC2 instances). When configuring an ALB Listener, multiple Target Groups can be attached, 
allowing the Listener to route incoming requests to different groups of targets based on your requirements.

The `target_groups` variable in our module is a list of objects, where each object represents a Target Group. 
Each object must provide the ARN of the Target Group (`arn`) and a weight (`weight`), which determines the proportion 
of traffic it should receive. 


target_groups = [
  {
    arn    = module.target_group_1.arn
    weight = 100
  },
  {
    arn    = module.target_group_2.arn
    weight = 50
  }
]

In this example, the first Target Group will receive approximately twice the amount of traffic as the second 
Target Group because it has twice the weight.

Listener Rules further allow for traffic segmentation across the Load Balancer. 
Each rule consists of a condition (for example, based on the request path or host header) and an action 
(which defines the Target Group to which requests that meet the condition should be routed).

To use Listener Rules with our module, you would create the rules separately using the aws_alb_listener_rule 
resource and reference the ARN of the Listener that our module creates. The rules can reference different 
Target Groups, allowing you to route different types of requests to different groups of targets.
