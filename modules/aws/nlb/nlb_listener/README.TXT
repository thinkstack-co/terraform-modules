################## HOW TO USE THE AWS_LB_LISTENER RESOURCE #########################################################

This guide will help you understand how to use variables with the `aws_lb_listener` resource block in Terraform.

#################### VARIABLES #####################################################################################

Below are the variables used in the `aws_lb_listener` resource block:

1. `lb_arn`: The ARN (Amazon Resource Name) of the Network Load Balancer.

2. `port`: The port on which the load balancer is listening.

3. 'protocol':  "For Network Load Balancers, valid values are TCP, TLS, UDP, and TCP_UDP. Not valid to use UDP or TCP_UDP if dual-stack mode is enabled."

4. `target_groups`: A list of maps defining target group ARNs and their corresponding weights for load balancing.


################################ MODULE EXAMPLE ###################################################################
Here's an example usage of the variables:  Keep in mind, the references to other modules are based on the other
resources in this NLB Resource Group.  You will need to have modules set for a Network Load Balancer and
target group(s) for this module to be relevant.

################################
SINGLE TARGET GROUP
###############################
module "aws_nlb_listener" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/nlb/nlb_listener?ref=dev_alb"

  load_balancer_arn = module.aws_nlb_load_balancer.lb_arn
  port = 80
  protocol = "TCP"
  target_group_arn = module.target_group_1.target_group_arn

  tags = {
    terraform   = "yes"
    created_by  = "Wesley Bey"
    environment = "prod"
    role        = "prod"
  }
}

####################################
MULTIPLE TARGET GROUPS
####################################
module "aws_nlb_listener" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/nlb/nlb_listener?ref=dev_alb"

  load_balancer_arn = module.aws_nlb_load_balancer.lb_arn
  port = 80
  protocol = "TCP"
  target_groups = [
    {
      arn = module.aws_prod_nlb_target_group_1.target_group_arn
      weight = 100
    }
    {
      arn = module.aws_prod_nlb_target_group_2.target_group_arn
      weight = 50
    }
  ]

  tags = {
    terraform   = "yes"
    created_by  = "Wesley Bey"
    environment = "prod"
    role        = "prod"
  }
}

############################ Target Groups and Load Balancer Listener Rules #####################################

In the AWS Elastic Load Balancer (ELB) ecosystem, Target Groups are used to route requests to one or more registered
targets (like EC2 instances). When configuring NLB Listener, multiple Target Groups can be attached,
allowing the Listener to route incoming requests to different groups of targets based on your requirements.

The `target_groups` variable in our module is a list of objects, where each object represents a Target Group.
Each object must provide the ARN of the Target Group (`target_group_arn`) and a weight (`weight`), which determines the proportion
of traffic it should receive.


target_groups = [
  {
    arn    = module.target_group_1.target_group_arn
    weight = 100
  },
  {
    arn    = module.target_group_2.target_group_arn
    weight = 50
  }
]

In this example, the first Target Group will receive approximately twice the amount of traffic as the second
Target Group because it has twice the weight.

Listener Rules further allow for traffic segmentation across the Load Balancer.
Each rule consists of a condition (for example, based on the request path or host header) and an action
(which defines the Target Group to which requests that meet the condition should be routed).

To use Listener Rules with our module, you would create the rules separately using the aws_nlb_listener_rule
resource and reference the ARN of the Listener that our module creates. The rules can reference different
Target Groups, allowing you to route different types of requests to different groups of targets.
