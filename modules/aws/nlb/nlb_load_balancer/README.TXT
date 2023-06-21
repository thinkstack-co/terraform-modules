################## HOW TO USE ALB_LOAD_BALANCER ##################################################################

This guide will help you understand how to use variables with the `aws_lb` resource block in Terraform.

#################### VARIABLES #####################################################################################

Below are the variables utilized in the aws_lb resource block:

1. `count`: Defines the number of Load Balancer instances to create.

2. `drop_invalid_header_fields`: A boolean flag to enable or disable the dropping of invalid header fields.

3. `enable_cross_zone_load_balancing`: A boolean flag that allows or disallows cross-zone load balancing.

4. `enable_deletion_protection`: A boolean flag that enables or disables deletion protection for the load balancer.

5. `enable_http2`: A boolean flag that enables or disables HTTP/2.

6. `idle_timeout`: The amount of time in seconds that the connection is allowed to be idle 
(no data has been sent over the connection) before it is closed by the load balancer.

7. `internal`: A boolean flag that indicates whether this load balancer is internal or external.

8. `ip_address_type`: Defines the type of IP addresses to use with the load balancers (IPv4 or dualstack).

9. `load_balancer_type`: The type of load balancer to create - either 'application' or 'network'.

10. `nlb_name`: The name to assign to the Network Load Balancer.

11. `security_groups`: The list of security group IDs to assign to the load balancer.

12. `subnets`: The list of subnet IDs to associate with the load balancer.

13. `access_logs`: This block defines the access logs settings, containing:
    - `bucket`: The name of the S3 bucket where access logs are stored.
    - `enabled`: A boolean flag to enable or disable access logs.
    - `prefix`: An optional prefix for the log file names.


################################ MODULE EXAMPLE ###################################################################
Here's an example usage of the variables:  Keep in mind, the references to other modules are based on the other 
resources in this NLB Resource Group.  You will need to have modules set for a listener and a target group for 
this module to be relevant.

module "aws_prod_nlb" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/nlb/nlb_load_balancer?ref=dev_alb"

  drop_invalid_header_fields       = false
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false
  idle_timeout                     = 60
  internal                         = false
  ip_address_type                  = "ipv4"
  load_balancer_type               = "network"
  nlb_name                         = "aws-prod-nlb"
  security_groups                  = ["sg-01234578901"]
  subnets                          = module.vpc.private_subnets


  access_logs_bucket  = "my-s3-bucket"
  access_logs_enabled = false
  access_logs_prefix  = "access-logs"

  tags = {
    terraform   = "yes"
    created_by  = "Wesley Bey"
    environment = "prod"
    role        = "prod"
  }
}
####################################################################################################################


