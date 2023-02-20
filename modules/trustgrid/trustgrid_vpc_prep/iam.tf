data "aws_iam_policy_document" "private-route-table-modifications" {
  statement {
      actions = ["ec2:DescribeRouteTables"]
      resources = ["*"]
  }

  statement {
      actions = [
          "ec2:CreateRoute",
          "ec2:DeleteRoute"
      ]
      resources = [var.route_table_arn]
  }
}

resource "aws_iam_role_policy" "trustgrid-route-policy" {
    name_prefix = "${var.environment_name}-trustgrid-route-policy"
    policy = data.aws_iam_policy_document.private-route-table-modifications.json
    role = aws_iam_role.trustgrid-node.name
}

resource "aws_iam_role" "trustgrid-node" {
    name_prefix = "${var.environment_name}-trustgrid-node"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "trustgrid-instance-profile" {
    name_prefix = "${var.environment_name}-trustgrid-instance-profile"
    role = aws_iam_role.trustgrid-node.name
}