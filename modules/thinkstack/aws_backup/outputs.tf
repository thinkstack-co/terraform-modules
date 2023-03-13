output "vault_hourly_arn" {
  value = aws_backup_vault.vault_prod_hourly.arn
}

output "vault_daily_arn" {
  value = aws_backup_vault.vault_prod_daily.arn
}

output "vault_monthly_arn" {
  value = aws_backup_vault.vault_prod_monthly.arn
}

output "vault_disaster_recovery_arn" {
  value = aws_backup_vault.vault_disaster_recovery.arn
}
