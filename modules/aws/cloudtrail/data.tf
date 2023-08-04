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
}


