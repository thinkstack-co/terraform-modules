terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

###################################
# Cloudwatch Log Destination Policy
###################################

resource "aws_cloudwatch_log_destination_policy" "this" {
  destination_name = aws_cloudwatch_log_destination.this.name
  access_policy    = var.destination_policy_access_policy
}

###########################
# IAM Policy
###########################
resource "aws_iam_policy" "firehose_policy" {
  description = var.iam_policy_description
  name_prefix = var.iam_policy_name_prefix
  path        = var.iam_policy_path
  tags        = var.tags
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:AbortMultipartUpload",
      ],
      Resource = [
        "${aws_s3_bucket.firehose_bucket.arn}",
        "${aws_s3_bucket.firehose_bucket.arn}/*"
      ]
    }]
  })
}

###########################
# IAM Role
###########################

resource "aws_iam_role" "firehose_role" {
  assume_role_policy    = var.iam_role_assume_role_policy
  description           = var.iam_role_description
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration  = var.iam_role_max_session_duration
  name_prefix           = var.iam_role_name_prefix
  permissions_boundary  = var.iam_role_permissions_boundary
}

resource "aws_iam_role_policy_attachment" "role_attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}



###################################
# Cloudwatch Log Destination
###################################

resource "aws_cloudwatch_log_destination" "this" {
  name       = var.destination_name
  role_arn   = aws_iam_role.iam_for_cloudwatch.arn
  target_arn = var.destination_target_arn
}
