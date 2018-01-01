resource "aws_sqs_queue" "queue" {
  fifo_queue  = "${var.fifo_queue}"
  name        = "${var.name}" 
}
