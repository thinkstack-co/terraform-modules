resource "aws_iam_policy" "mfa_self_serv" {
  name        = var.mfa_self_serv_name
  description = "Allows users to manage their own MFA settings"
  policy      = file("${path.module}/mfa_enforcement_policy.json")
}