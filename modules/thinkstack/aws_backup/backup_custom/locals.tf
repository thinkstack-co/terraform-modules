locals {
  create_prod_key = anytrue([for job in var.backup_jobs : !job.dr_region])
  create_dr_key   = anytrue([for job in var.backup_jobs : job.dr_region])
}

