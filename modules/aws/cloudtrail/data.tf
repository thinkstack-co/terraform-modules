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
    sid    = "CloudTrailS3Access"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.cloudtrail.arn,
      "${aws_s3_bucket.cloudtrail.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "CloudTrailKMSAccess"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [aws_kms_key.cloudtrail.arn]
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


  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
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

    # Specifies that the CloudTrail service is the principal allowed to perform the action
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    # Specifies the allowed action to get the bucket ACL
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail.arn]
  }

  # Statement to allow CloudTrail to write logs to the S3 bucket
  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    # Specifies that the CloudTrail service is the principal allowed to perform the action
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    # Specifies the allowed action to put objects (logs) into the S3 bucket
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail.arn}/*"]


    # Condition to ensure that the bucket owner has full control over the objects
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}
