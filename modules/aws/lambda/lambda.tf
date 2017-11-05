resource "aws_lambda_function" "lambda_function" {
    description         = "${var.lambda_description}"
    filename            = "${var.lambda_filename}"
    source_code_hash    = "${var.source_code_hash}"
    function_name       = "${var.lambda_function_name}"
    role                = "${var.lambda_role}"
    handler             = "${var.lambda_handler}"
    runtime             = "${var.lambda_runtime}"
    timeout             = "${var.lambda_timeout}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
    statement_id    = "${var.statement_id}"
    action          = "${var.action}"
    function_name   = "${aws_lambda_function.lambda_function.function_name}"
    principal       = "${var.principal}"
    source_arn      = "${var.source_arn}"
}
