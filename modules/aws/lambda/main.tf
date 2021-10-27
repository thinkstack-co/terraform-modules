terraform {
  required_version = ">= 0.12.0"
}

resource "aws_lambda_function" "lambda_function" {
  description = var.description
  environment {
    variables = var.variables
  }
  filename         = var.filename
  function_name    = var.function_name
  handler          = var.handler
  memory_size      = var.memory_size
  role             = var.role
  runtime          = var.runtime
  source_code_hash = var.source_code_hash
  timeout          = var.timeout
}

/*resource "aws_lambda_permission" "allow_cloudwatch" {
    statement_id    = var.statement_id
    action          = var.action
    function_name   = aws_lambda_function.lambda_function.function_name
    principal       = var.principal
    source_arn      = var.source_arn
}
*/
