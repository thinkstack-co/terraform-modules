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

  role_name = "${var.project_name}-weekly-backup-role"
  tags      = var.tags
}

# Create weekly backup vault (uses AWS-managed keys by default)
module "backup_vaults" {
  source = "../../modules/aws_backup_vault"
  
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  create_single_vault = false
  vault_name_prefix   = var.project_name
  
  # Enable only weekly vault
  enable_hourly_vault  = false
  enable_daily_vault   = false
  enable_weekly_vault  = true
  enable_monthly_vault = false
  enable_yearly_vault  = false
  
  # DR configuration (optional)
  enable_dr              = var.enable_dr
  enable_weekly_dr_vault = var.enable_dr
  dr_vault_name_prefix   = "${var.project_name}-dr"
  
  # Vault lock for compliance (optional)
  enable_vault_lock         = var.enable_vault_lock
  weekly_min_retention_days = 30  # 30 days minimum
  
  tags = var.tags
}

# Create weekly backup plan
module "weekly_backup_plan" {
  source = "../../modules/aws_backup_plans"

  name                    = "backup_plan"
  plan_prefix             = var.project_name
  create_backup_selection = true
  
  # Server selection - tag your servers with: WeeklyBackup = "true"
  server_selection_tag   = "WeeklyBackup"
  server_selection_value = "true"
  
  # Enable only weekly schedule
  enable_hourly_plan  = false
  enable_daily_plan   = false
  enable_weekly_plan  = true
  enable_monthly_plan = false
  enable_yearly_plan  = false
  
  # Weekly configuration
  weekly_schedule          = "cron(0 2 ? * SUN *)"  # 2 AM every Sunday
  weekly_vault_name        = module.backup_vaults.scheduled_vault_names["weekly"]
  weekly_start_window      = 60    # 60 minute backup window
  weekly_completion_window = 360   # Complete within 6 hours
  
  # Production retention
  weekly_retention_days     = 35    # Keep production backups for 5 weeks
  weekly_cold_storage_after = null  # No cold storage for weekly
  
  # DR copy configuration (optional)
  enable_weekly_dr_copy        = var.enable_dr
  weekly_dr_vault_arn          = var.enable_dr ? module.backup_vaults.dr_vault_arns["weekly"] : null
  weekly_dr_retention_days     = 14    # Keep DR copies for 2 weeks
  weekly_dr_cold_storage_after = null  # No cold storage for DR
  
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
      Name         = "${var.project_name}-weekly-backup-example"
      WeeklyBackup = "true"  # This tag triggers weekly backups
    }
  )
}

# Example EBS volume to backup
resource "aws_ebs_volume" "example" {
  count = var.create_example_resources ? 1 : 0
  
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 10
  encrypted         = true
  
  tags = merge(
    var.tags,
    {
      Name         = "${var.project_name}-weekly-backup-volume"
      WeeklyBackup = "true"  # This tag triggers weekly backups
    }
  )
}

# Example EFS file system to backup
resource "aws_efs_file_system" "example" {
  count = var.create_example_resources ? 1 : 0
  
  encrypted = true
  
  tags = merge(
    var.tags,
    {
      Name         = "${var.project_name}-weekly-backup-efs"
      WeeklyBackup = "true"  # This tag triggers weekly backups
    }
  )
}

# Data sources
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}