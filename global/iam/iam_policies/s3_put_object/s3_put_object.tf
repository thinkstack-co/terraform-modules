# DO NOT REMOVE THIS LINE. Required for account_id references in locals and resources.
data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "s3_put_object" {
  name        = var.s3_put_object_name
  description = "Allows users to put objects in s3 buckets"
  policy      = file("${path.module}/s3_put_object.json")
}
