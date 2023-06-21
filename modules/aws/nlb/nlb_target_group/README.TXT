################## HOW TO USE THE ALB_TARGET_GROUP RESOURCE #########################################################

This guide will help you understand how to use variables with the `aws_lb_target_group` and 
'aws_lb_target_group_attachment resource block in Terraform.

#################### VARIABLES #####################################################################################

Below are the variables used in the `aws_lb_listener` resource block:

1. name: The unique name of the target group.

2. target_type: Specifies the type of target that requests are routed to. For an ALB, this should be "alb".

3. port: The port where the target group directs traffic.

4. protocol: Defines the protocol to use for routing traffic.

5. vpc_id: The identifier of the VPC in which to create the target group.

6. health_check: A nested block that defines a health check. 
   It consists of parameters like protocol, port, path, timeout, interval, healthy_threshold, 
   unhealthy_threshold, and matcher.

The aws_lb_target_group_attachment resource block manages the registration of a target to an AWS target group. 
Below are its main variables:

1. target_group_arn: The ARN (Amazon Resource Name) of the target group to which to attach targets.

2. target_id: The identifier of the target to attach. This could be an Instance ID, IP address, or the ID of a Lambda function.

3. port: The port on which targets receive traffic.

################################ MODULE EXAMPLE ###################################################################
Here's an example usage of the variables:  Keep in mind, the references to other modules are based on the other 
resources in this ALB Resource Group.  You will need to have modules set for an Application Load Balancer and  
Listener for this module to be relevant.

module "aws_prod_amplify_alb_target_group_1" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_target_group?ref=dev_alb"  

  name                            = "aws-prod-target-group1"
  target_type                     = "instance"
  port                            = 80
  protocol                        = "TCP"
  proxy_protocol_v2               = false
  vpc_id                          = module.vpc.vpc_id
  health_check_protocol           = "HTTPS"
  health_check_port               = "traffic-port"
  health_check_path               = "/"
  health_check_timeout_seconds    = 5
  health_check_interval_seconds   = 30
  healthy_threshold_count         = 5
  unhealthy_threshold_count       = 2
  matcher                         = "200-399"
  target_id                       = "i-01234567890"
  target_group_arn                = module.aws-prod-target-group1.target_group_arn 
      
  tags = {
    terraform   = "yes"
    created_by  = "Wesley Bey"
    environment = "prod"
    role        = "prod"
  }
}


############################ Ports and Protocols #####################################

Protocol: The listener and the target group should use compatible protocols. For example, if you are using a TCP listener, 
the target group should be able to accept TCP traffic.

Ports: The listener port is the port that the Application Load Balancer (ALB) listens on for incoming client connections. 
The port that you specify for the target group is the port on which the registered targets (your instances or services) 
are listening. If your targets are listening on the same port as the ALB, then these ports would be the same.

However, it's also possible for these ports to be different. For example, you might have an ALB that listens for incoming 
connections on port 80 (HTTP), but then forwards those connections to targets listening on port 8080. In this case, 
you would set the listener port to 80 and the target group port to 8080.


