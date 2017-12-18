resource "aws_iam_group" "powerusers" {
  name          = "${var.powerusers_group_name}"
}

resource "aws_iam_group_policy_attachment" "powerusers" {
    group       = "${aws_iam_group.powerusers.name}"
    policy_arn  = "${var.powerusers_policy_arn}"
}

resource "aws_iam_group_policy_attachment" "powerusers_mfa" {
    group       = "${aws_iam_group.powerusers.name}"
    policy_arn  = "${var.mfa_policy_arn}"
}

resource "aws_iam_group" "billing" {
  name          = "${var.billing_group_name}"
}

resource "aws_iam_group_policy_attachment" "billing" {
    group       = "${aws_iam_group.billing.name}"
    policy_arn  = "${var.billing_policy_arn}"
}

resource "aws_iam_group_policy_attachment" "billing_mfa" {
    group       = "${aws_iam_group.billing.name}"
    policy_arn  = "${var.mfa_policy_arn}"
}

resource "aws_iam_group" "readonly" {
  name          = "${var.readonly_group_name}"
}

resource "aws_iam_group_policy_attachment" "readonly" {
    group       = "${aws_iam_group.readonly.name}"
    policy_arn  = "${var.readonly_policy_arn}"
}

resource "aws_iam_group_policy_attachment" "readonly_mfa" {
    group       = "${aws_iam_group.readonly.name}"
    policy_arn  = "${var.mfa_policy_arn}"
}

resource "aws_iam_group" "sms_connector" {
    name        = "${var.sms_connector_group_name}"
}

resource "aws_iam_group_policy_attachment" "sms_connector_policy" {
    group       = "${aws_iam_group.sms_connector.name}"
    policy_arn  = "${var.sms_connector_policy_arn}"
}
