# Outputs for AWS Cost Report Module

output "cost_report_pdf_url" {
  description = "The S3 URL of the latest cost report PDF."
  value       = aws_s3_object.cost_report_pdf.bucket != null && aws_s3_object.cost_report_pdf.key != null ? "https://${aws_s3_object.cost_report_pdf.bucket}.s3.amazonaws.com/${aws_s3_object.cost_report_pdf.key}" : null
}

output "lambda_function_arn" {
  description = "The ARN of the cost report Lambda function."
  value       = aws_lambda_function.cost_reporter.arn
}
