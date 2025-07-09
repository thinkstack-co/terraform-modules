terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# DR region provider for cross-region backups
provider "aws" {
  alias  = "dr"
  region = var.dr_region
}

# Create IAM role for AWS Backup
module "backup_iam_role" {
  source = "../../modules/aws_backup_iam_role"

  role_name = "${var.project_name}-monthly-backup-role"
  tags      = var.tags
}

# Create monthly backup vault (uses AWS-managed keys by default)
module "backup_vaults" {
  source = "../../modules/aws_backup_vault"
  
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  create_single_vault = false
  vault_name_prefix   = var.project_name
  
  # Enable only monthly vault
  enable_hourly_vault  = false
  enable_daily_vault   = false
  enable_weekly_vault  = false
  enable_monthly_vault = true
  enable_yearly_vault  = false
  
  # DR configuration (optional)
  enable_dr               = var.enable_dr
  enable_monthly_dr_vault = var.enable_dr
  dr_vault_name_prefix    = "${var.project_name}-dr"
  
  # Vault lock for compliance (optional)
  enable_vault_lock          = var.enable_vault_lock
  monthly_min_retention_days = 365  # 1 year minimum
  
  tags = var.tags
}

# Create monthly backup plan
module "monthly_backup_plan" {
  source = "../../modules/aws_backup_plans"

  name                    = "backup_plan"
  plan_prefix             = var.project_name
  create_backup_selection = true
  
  # Server selection - tag your servers with: MonthlyBackup = "true"
  server_selection_tag   = "MonthlyBackup"
  server_selection_value = "true"
  
  # Enable only monthly schedule
  enable_hourly_plan  = false
  enable_daily_plan   = false
  enable_weekly_plan  = false
  enable_monthly_plan = true
  enable_yearly_plan  = false
  
  # Monthly configuration
  monthly_schedule          = "cron(0 3 1 * ? *)"  # 3 AM on the 1st of each month
  monthly_vault_name        = module.backup_vaults.scheduled_vault_names["monthly"]
  monthly_start_window      = 60    # 60 minute backup window
  monthly_completion_window = 480   # Complete within 8 hours
  
  # Production retention
  monthly_retention_days     = 365   # Keep production backups for 1 year
  monthly_cold_storage_after = 90    # Move to cold storage after 90 days
  
  # DR copy configuration (optional)
  enable_monthly_dr_copy        = var.enable_dr
  monthly_dr_vault_arn          = var.enable_dr ? module.backup_vaults.dr_vault_arns["monthly"] : null
  monthly_dr_retention_days     = 180   # Keep DR copies for 6 months
  monthly_dr_cold_storage_after = null  # No cold storage for DR
  
  tags = var.tags
}

# Example EC2 instance to backup
resource "aws_instance" "example" {
  count = var.create_example_resources ? 1 : 0
  
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  
  tags = merge(
    var.tags,
    {
      Name          = "${var.project_name}-monthly-backup-example"
      MonthlyBackup = "true"  # This tag triggers monthly backups
    }
  )
}

# Example RDS database to backup
resource "aws_db_instance" "example" {
  count = var.create_example_resources ? 1 : 0
  
  identifier     = "${var.project_name}-monthly-backup-db"
  engine         = "postgres"
  engine_version = "14.7"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_encrypted = true
  
  username = "admin"
  password = "changeme123!"  # Change this in production!
  
  skip_final_snapshot = true
  
  tags = merge(
    var.tags,
    {
      Name          = "${var.project_name}-monthly-backup-db"
      MonthlyBackup = "true"  # This tag triggers monthly backups
    }
  )
}

# Data source for AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}