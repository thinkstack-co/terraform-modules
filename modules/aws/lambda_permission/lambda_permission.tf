resource "aws_lambda_permission" "allow_cloudwatch" {
    statement_id    = "${var.statement_id}"
    action          = "${var.action}"
    function_name   = "${var.function_name}"
    principal       = "${var.principal}"
    source_arn      = "${var.source_arn}"
}
