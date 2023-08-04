# The aws_iam_policy_document for CloudTrail constructs an IAM policy document that grants 
# permissions for CloudTrail to create and write to CloudWatch Log streams.
data "aws_iam_policy_document" "cloudtrail" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
    ]
  }

  statement {
    actions = [
      "s3:PutObject", "s3:GetBucketAcl"
    ]

    resources = [
      aws_s3_bucket.cloudtrail.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}


# The aws_iam_policy_document for CloudTrail Assume constructs an IAM policy document that 
# allows CloudTrail service to assume an IAM role. This is necessary to give CloudTrail the 
# permissions it needs to carry out actions on your behalf.
data "aws_iam_policy_document" "cloudtrail_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

# The aws_iam_policy_document for Key Policy constructs an IAM policy document that grants 
# permissions for the root user of your AWS account to perform any action on KMS resources. 
# This is required to allow encryption and decryption operations for CloudTrail with KMS.
data "aws_iam_policy_document" "key_policy" {
  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "s3_bucket_policy" {

  # Statement to allow CloudTrail to check the Access Control List (ACL) of the S3 bucket
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail.arn]

    # Condition to match the ARN of the specific CloudTrail trail
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${aws_cloudtrail.cloudtrail.name}"]
    }
  }

  # Statement to allow CloudTrail to write logs to the S3 bucket
  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${aws_cloudtrail.cloudtrail.name}"]
    }
  }

  # Additional statement to deny all public access
  statement {
    sid     = "DenyAllPublicAccess"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}",
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
