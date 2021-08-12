resource "aws_iam_policy" "mfa_enforcement" {
  name        = var.mfa_enforcement_name
  description = "Allows users to manage their own MFA settings"
  policy      = file("./mfa_enforcement_policy.json")
}