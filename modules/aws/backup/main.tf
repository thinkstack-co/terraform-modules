resource "aws_backup_vault" "this" {
  kms_key_arn = var.kms_key_arn
  name        = var.vault_name
  tags        = var.tags
}

resource "aws_backup_plan" "this" {
  name = 
  rule {}
  tags = var.tags
}
