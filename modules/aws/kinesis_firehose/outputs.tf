output "arn" {
  description = "ARN of the kinesis firehose stream"
  value       = aws_kinesis_firehose_delivery_stream.extended_s3_stream[*].id
}