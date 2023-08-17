terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

###################
# AWS ACCOUNT
###################
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


#################
# BUCKET
#################

resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.bucket_name_prefix
  acl           = var.bucket_acl
  force_destroy = var.destroy_objects_with_bucket # This only deletes objects when the bucket is destroyed, not when setting this parameter to true. 
}

########################
# BLOCK PUBLIC ACCESS
########################

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count  = var.enable_public_access_block ? 1 : 0 # Conditionally create resource
  bucket = aws_s3_bucket.bucket.id                # The name of the bucket

  block_public_acls       = var.block_public_acls       # Whether Amazon S3 should block public ACLs for this bucket
  block_public_policy     = var.block_public_policy     # Whether Amazon S3 should block public bucket policies for this bucket
  ignore_public_acls      = var.ignore_public_acls      # Whether Amazon S3 should ignore public ACLs for this bucket
  restrict_public_buckets = var.restrict_public_buckets # Whether Amazon S3 should restrict public bucket policies for this bucket
}

#######################
# VERSIONING
#######################

resource "aws_s3_bucket_versioning" "versioning" {
  count  = var.enable_versioning ? 1 : 0 # This will create the resource if enable_versioning is true, and skip if it's false
  bucket = aws_s3_bucket.bucket.id       # The name of the bucket

  versioning_configuration {
    status     = var.versioning_status
    mfa_delete = var.mfa_delete
  }
}

#####################
# ACCELERATION
#####################

resource "aws_s3_bucket_accelerate_configuration" "acceleration" {
  count  = var.enable_acceleration ? 1 : 0 # Conditionally create resource
  bucket = aws_s3_bucket.bucket.id         # The name of the bucket
  status = var.accelerate_status           # The accelerate status of the bucket, "Enabled" or "Suspended"
}

######################
# INTELLIGENT TIERING
######################

resource "aws_s3_bucket_intelligent_tiering_configuration" "intelligent_tiering" {
  count  = var.enable_intelligent_tiering ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  name   = var.tiering_config_id
  status = "Enabled"

  # Static block for Archive Access tier
  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 90
  }

  # Static block for Deep Archive Access tier
  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }
}


############################
# LIFECYCLE CONFIGURATION
############################

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  count  = var.enable_lifecycle_configuration ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = var.lifecycle_rule_id
    status = "Enabled"

    # Transition to S3 Standard-IA based on user-defined days
    dynamic "transition" {
      for_each = var.enable_standard_ia ? [var.days_to_standard_ia] : []
      content {
        days          = transition.value
        storage_class = "STANDARD_IA"
      }
    }

    # Transition to S3 One Zone-IA based on user-defined days
    dynamic "transition" {
      for_each = var.enable_onezone_ia ? [var.days_to_onezone_ia] : []
      content {
        days          = transition.value
        storage_class = "ONEZONE_IA"
      }
    }

    # Transition to S3 Glacier Instant Retrieval based on user-defined days
    dynamic "transition" {
      for_each = var.enable_glacier_instant ? [var.days_to_glacier_instant] : []
      content {
        days          = transition.value
        storage_class = "GLACIER_INSTANT_RETRIEVAL"
      }
    }

    # Transition to S3 Glacier Flexible Retrieval based on user-defined days
    dynamic "transition" {
      for_each = var.enable_glacier_flexible ? [var.days_to_glacier_flexible] : []
      content {
        days          = transition.value
        storage_class = "GLACIER_FLEXIBLE_RETRIEVAL"
      }
    }

    # Transition to S3 Glacier Deep Archive based on user-defined days
    dynamic "transition" {
      for_each = var.enable_deep_archive ? [var.days_to_deep_archive] : []
      content {
        days          = transition.value
        storage_class = "DEEP_ARCHIVE"
      }
    }
  }
}

#######
# SSE
#######

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.create_kms_key ? aws_kms_key.s3_encryption_key[0].arn : var.kms_master_key_id
    }

    bucket_key_enabled = var.bucket_key_enabled
  }
}

resource "aws_kms_key" "s3_encryption_key" {
  count       = var.create_kms_key ? 1 : 0
  description = "KMS Key for S3 Bucket Encryption"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "s3.amazonaws.com"
        },
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : "*",
        Condition : {
          StringEquals : {
            "s3:arn" : "${aws_s3_bucket.bucket.arn}"
          }
        }
      },
      {
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action : "kms:PutKeyPolicy",
        Resource : "*"
      },
      {
        Sid: "AllowEntitiesWithAdminPolicy",
        Effect: "Allow",
        Principal: {
          "AWS": "*"
        },
        Action: "kms:*",
        Resource : "*",
        Condition: {
          StringEquals: {
            "aws:RequesterManagedPolicyArn": "arn:aws:iam::aws:policy/AdministratorAccess"
          }
        }
      }
    ]
  })
}


# IAM Role for S3 to use KMS Key
resource "aws_iam_role" "s3_kms_role" {
  count = var.create_kms_key ? 1 : 0
  name  = "S3KMSEncryptionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}


##################
# REPLICATION
##################

# S3 BUCKET REPLICATION CONFIGURATION
resource "aws_s3_bucket_replication_configuration" "replication_configuration" {
  count  = var.enable_replication ? 1 : 0 # This will create the resource if enable_replication is true, and skip if it's false
  bucket = aws_s3_bucket.bucket.id
  role   = aws_iam_role.source_replication_role[count.index].arn

  rule {
    id     = var.replication_rule_id
    status = var.replication_rule_status

    destination {
      # Use the ARN of the created bucket if 'create_destination_bucket' is true, otherwise use the provided ARN.
      bucket        = var.create_destination_bucket ? aws_s3_bucket.destination_bucket[count.index].arn : var.target_bucket_arn
      storage_class = var.replication_storage_class
    }
  }
}

# IAM ROLE FOR SOURCE BUCKET
resource "aws_iam_role" "source_replication_role" {
  count = var.enable_replication ? 1 : 0
  name  = "SourceBucketReplicationRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

# IAM ROLE FOR DESTINATION BUCKET
resource "aws_iam_role" "destination_replication_role" {
  count = var.enable_replication ? 1 : 0
  name  = "DestinationBucketReplicationRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

# POLICIES - REFERENCE DATA.TF
resource "aws_iam_policy" "source_bucket_policy" {
  count = var.enable_replication ? 1 : 0

  name        = "SourceBucketReplicationPolicy"
  description = "Policy for source bucket replication permissions"
  policy      = data.aws_iam_policy_document.source_replication_policy[count.index].json
}

resource "aws_iam_policy" "destination_bucket_policy" {
  count = var.enable_replication ? 1 : 0

  name        = "DestinationBucketReplicationPolicy"
  description = "Policy for destination bucket replication permissions"
  policy      = data.aws_iam_policy_document.destination_replication_policy[count.index].json
}

# POLICY ATTACHMENTS
resource "aws_iam_role_policy_attachment" "source_replication_attachment" {
  count      = var.enable_replication ? 1 : 0
  role       = aws_iam_role.source_replication_role[count.index].name
  policy_arn = aws_iam_policy.source_bucket_policy[count.index].arn
}

resource "aws_iam_role_policy_attachment" "destination_replication_attachment" {
  count      = var.create_destination_bucket ? 1 : 0
  role       = aws_iam_role.destination_replication_role[count.index].name
  policy_arn = aws_iam_policy.destination_bucket_policy[count.index].arn
}

# OPTIONAL DESTINATION BUCKET CREATION
resource "aws_s3_bucket" "destination_bucket" {
  count  = var.create_destination_bucket ? 1 : 0
  bucket = var.destination_bucket_name
  acl    = var.destination_bucket_acl
}

resource "aws_s3_bucket_versioning" "destination_bucket_versioning" {
  count  = var.create_destination_bucket ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status     = var.destination_bucket_status
    mfa_delete = var.destination_bucket_mfa_delete ? "Enabled" : "Disabled"
  }
}



