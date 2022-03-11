################################################################################################################################
# CloudTrail Modules
################################################################################################################################

module "cloudtrail" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/cloudtrail?ref=v0.4.5"

  acl           = "private"
  bucket_prefix = "your-cloudtrail-"
  region        = "us-east-2"

  # Enabling MFA delete requires the root account or an IAM account with mfa passed via the CLI. 
  # Run first as false, modify it manually then flip to 'true'
  # aws s3api put-bucket-versioning –profile MasterUser –bucket MyVersionBucket –versioning-configuration MFADelete=Enabled,Status=Enabled –mfa ‘arn:…. 012345‘
  mfa_delete = false

  # Used if you want to set a specific kms key
  # cloudtrail_kms_key  =   module.primary_kms_key.kms_key_arn
}
