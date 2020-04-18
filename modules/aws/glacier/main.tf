resource "aws_sns_topic" "this" {
  name = var.sns_topic_name
}

resource "aws_glacier_vault" "this" {
  access_policy = var.access_policy
  name          = var.vault_name
  tags          = var.tags
  
  notification {
    sns_topic = "${aws_sns_topic.this.arn}"
    events    = ["ArchiveRetrievalCompleted", "InventoryRetrievalCompleted"]
  }
}
