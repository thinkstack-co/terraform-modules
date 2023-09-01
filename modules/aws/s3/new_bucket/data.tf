# IAM policy data for source bucket replication permissions
data "aws_iam_policy_document" "source_replication_policy" {
  count = var.enable_replication ? 1 : 0

  statement {
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging",
      "s3:ListBucket",
      "s3:GetReplicationConfiguration",
      "s3:GetBucketVersioning",
      "s3:GetBucketLocation"
    ]

    effect = "Allow"

    resources = [
      "${aws_s3_bucket.bucket.arn}",
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

# IAM policy data for destination bucket replication permissions
data "aws_iam_policy_document" "destination_replication_policy" {
  count = var.enable_replication ? 1 : 0

  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:GetBucketVersioning",
      "s3:ListBucket"
    ]

    effect = "Allow"
    resources = [
      "${aws_s3_bucket.destination_bucket[count.index].arn}",
    "${aws_s3_bucket.destination_bucket[count.index].arn}/*"]
  }
}
