S3 Website Bucket Module
=================

This module sets up an EC2 instance with the parameters specified. This module has root block devices modifiable


# Usage
        module "s3_prod_website_pub_bucket" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/s3_website"
        
        policy = file("global/s3/bucket_policies/this-is-a-policy.json")
        bucket_prefix = "this-is-a-bucket-prefix"
        region = "us-west-1"
        acl    = "public-read"
        
    }

        tags                   = {
            terraform   = "yes"
            created_by  = "terraform"
            environment = "prod"
            role        = "website_bucket"
        }

# Variables
## Required
    bucket_prefix (requried because "bucket" is not in use)
    index_document


## Optional
    error_document
    acl
    policy
    region
    tags
    versioning
    mfa_delete
    tags


# Outputs
    s3_bucket_id
    s3_bucket_arn
    s3_bucket_domain_name
    s3_hosted_zone_id
    s3_bucket_region
