output "arn" {
  value = aws_dynamodb_table.this.arn
}

output "id" {
  value = aws_dynamodb_table.this.id
}

output "stream_arn" {
  value = aws_dynamodb_table.this.stream_arn
}

output "stream_label" {
  value = aws_dynamodb_table.this.stream_label
}
