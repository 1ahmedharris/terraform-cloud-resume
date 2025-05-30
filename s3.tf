

data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket" "bucket_config" {
  bucket = "aitc-s3"

}


resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_config_sse" {
  bucket = aws_s3_bucket.bucket_config.id

  rule {
    bucket_key_enabled = true 
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}


resource "aws_s3_bucket_versioning" "bucket_config_versioning" {
  bucket = aws_s3_bucket.bucket_config.id

  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled" 
  }
}


