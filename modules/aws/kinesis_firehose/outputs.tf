output "arn" {
  description = "ARN of the kinesis firehose delivery stream."
  value       = aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
}
