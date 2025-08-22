resource "aws_iam_group" "powerusers" {
  name = var.powerusers_group_name
}

resource "aws_iam_group_policy_attachment" "powerusers" {
  group      = aws_iam_group.powerusers.name
  policy_arn = var.powerusers_policy_arn
}

resource "aws_iam_group_policy_attachment" "powerusers_mfa" {
  group      = aws_iam_group.powerusers.name
  policy_arn = var.mfa_policy_arn
}

resource "aws_iam_group" "billing" {
  name = var.billing_group_name
}

resource "aws_iam_group_policy_attachment" "billing" {
  group      = aws_iam_group.billing.name
  policy_arn = var.billing_policy_arn
}

resource "aws_iam_group_policy_attachment" "billing_mfa" {
  group      = aws_iam_group.billing.name
  policy_arn = var.mfa_policy_arn
}

resource "aws_iam_group" "readonly" {
  name = var.readonly_group_name
}

resource "aws_iam_group_policy_attachment" "readonly" {
  group      = aws_iam_group.readonly.name
  policy_arn = var.readonly_policy_arn
}

resource "aws_iam_group_policy_attachment" "readonly_mfa" {
  group      = aws_iam_group.readonly.name
  policy_arn = var.mfa_policy_arn
}

resource "aws_iam_group" "sms_connector" {
  name = var.sms_connector_group_name
}

resource "aws_iam_group_policy_attachment" "sms_connector_policy" {
  group      = aws_iam_group.sms_connector.name
  policy_arn = var.sms_connector_policy_arn
}

resource "aws_iam_group" "system_admins" {
  name = var.system_admins_group_name
}

resource "aws_iam_policy" "system_admins_policy" {
  description = var.system_admins_description
  name        = var.system_admins_name
  path        = var.system_admins_path
  policy      = file("${path.module}/iam_policies/system_admins/system-admins-policy.json")
}

resource "aws_iam_group_policy_attachment" "system_admins" {
  group      = aws_iam_group.system_admins.name
  policy_arn = aws_iam_policy.system_admins_policy.arn
}

resource "aws_iam_group_policy_attachment" "system_admins_mfa" {
  group      = aws_iam_group.system_admins.name
  policy_arn = var.mfa_policy_arn
}
