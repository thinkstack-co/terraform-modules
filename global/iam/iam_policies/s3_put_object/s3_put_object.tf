resource "aws_iam_policy" "s3_put_object" {
  name        = var.s3_put_object_name
  description = "Allows users to put objects in s3 buckets"
  policy      = file("${path.module}/s3_put_object.json")
}
