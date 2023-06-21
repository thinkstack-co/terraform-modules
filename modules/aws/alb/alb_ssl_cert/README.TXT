################## HOW TO USE ALB_SSL_CERT ##################################################################

This guide will help you understand how to use variables with the `aws_acm_certificate` resource block in Terraform.

#################### VARIABLES #####################################################################################

Below are the variables used in the `aws_acm_certificate` resource block:

1. `domain_name`: A domain name for which the certificate should be issued.

2. `validation_method`: Which method to use for validation. DNS or EMAIL are valid, NONE can be used for certificates that were imported into ACM and then into Terraform.

3. `subject_alternative_names`: A list of domains that should be SANs in the issued certificate.

4. `key_algorithm`: Specifies the algorithm of the public and private key pair that your Amazon issued certificate uses to encrypt data. See ACM Certificate characteristics for more details..

5. `listener_arn`: The ARN of the listener to which to attach the certificate.

6. 'certificate_arn' : The ARN of the certificate to attach to the listener.


################################ MODULE EXAMPLE ###################################################################
Here's an example usage of the variables:  Keep in mind, the references to other modules are based on the other 
resources in this ALB Resource Group.  You will need to have modules set for a listener for this module to be relevant.

module "aws_prod_amplify_alb_ssl_certificate" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_ssl_cert?ref=dev_alb"

  domain_name                = "www.domain.org"
  validation_method          = "DNS"
  subject_alternative_names  = ["app.domain.org"]
  key_algorithm              = "RSA_2048"
  tags = {
    Environment = "prod"
    Project = "prod"
  }
  listener_arn               = module.aws_prod_alb_listener.listener_arn
  certificate_arn            = module.aws_prod_alb_ssl_certificate.acm_certificate_arn
}
