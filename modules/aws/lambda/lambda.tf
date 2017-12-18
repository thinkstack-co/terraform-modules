resource "aws_lambda_function" "lambda_function" {
    description         = "${var.description}"
    filename            = "${var.filename}"
    source_code_hash    = "${var.source_code_hash}"
    function_name       = "${var.function_name}"
    role                = "${var.role}"
    handler             = "${var.handler}"
    memory_size         = "${var.memory_size}"
    runtime             = "${var.runtime}"
    timeout             = "${var.timeout}"
}

/*resource "aws_lambda_permission" "allow_cloudwatch" {
    statement_id    = "${var.statement_id}"
    action          = "${var.action}"
    function_name   = "${aws_lambda_function.lambda_function.function_name}"
    principal       = "${var.principal}"
    source_arn      = "${var.source_arn}"
}
*/
