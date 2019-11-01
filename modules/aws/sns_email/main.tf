terraform {
  required_version = ">= 0.12.0"
}

resource "aws_sns_topic" "topic" {
  display_name = var.display_name
  name         = var.name
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.topic.id
  protocol  = var.protocol
  endpoint  = "arn:aws:sqs:us-west-2:432981146916:terraform-queue-too"
}
