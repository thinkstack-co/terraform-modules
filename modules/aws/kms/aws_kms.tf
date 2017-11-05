resource "aws_kms_key" "key" {
    description             = "${var.kms_key_description}"
    deletion_window_in_days = "${var.kms_key_deletion_window}"
}
