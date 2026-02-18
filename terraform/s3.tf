# Bucket to store application source bundles (.zip files)
resource "aws_s3_bucket" "eb_artifacts" {
  bucket = "vijaya-eb-artifacts-v2-${data.aws_caller_identity.current.account_id}"   
  tags = {
    Name = "eb-artifacts"
    Environment = "prod"
  } 
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [bucket]
  }
}

#Enable versioning for safety
resource "aws_s3_bucket_versioning" "eb_artifacts_versioning" {
    bucket = aws_s3_bucket.eb_artifacts.id
    versioning_configuration {
      status = "Enabled"
    }
}

#Lifecycle rule to delete old versions after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "eb_artifacts_lifecycle" {
  bucket = aws_s3_bucket.eb_artifacts.id    
  rule {
    id = "archive-old-versions"
    status = "Enabled"
    expiration {
      days = 90
    }
    }
  }
