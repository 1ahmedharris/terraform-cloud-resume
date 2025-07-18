data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket" "bucket_config" {
  bucket = var.s3_bucket 
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_config_sse" {
  bucket = var.s3_bucket
  
  rule {
    bucket_key_enabled = true 
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "bucket_config_versioning" {
  bucket = var.s3_bucket

  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled" 
  }
}

resource "aws_s3_bucket_policy" "bucket_config_policy" {
  bucket = var.s3_bucket

  policy = jsonencode(
    {
      Version   = "2012-10-17"
      Statement = [
        {
          Sid       = "AllowCloudFrontServicePrincipalReadOnly"
          Effect    = "Allow"
          Principal = {
            Service = "cloudfront.amazonaws.com"
          }
          Action    = "s3:GetObject"
          Resource  = "${aws_s3_bucket.bucket_config.arn}/*"
          Condition = {
            StringEquals = {
              "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cloudfront_cdn.id}"

            }
          }
        },
      ]
    }
  )
}
