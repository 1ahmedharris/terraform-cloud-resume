data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket" "bucket_config" {
  bucket = var.s3_bucket 
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

resource "aws_s3_bucket_policy" "bucket_config_policy" {
  bucket = aws_s3_bucket.bucket_config.id

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

# Defines site local filepath values 
locals {
  files = fileset(var.website_content_path, "**/*")
  object_map = {
    for file in local.files :
    file => {
      source_path  = "${var.website_content_path}/${file}" 
      content_type = lookup(
        {
          "html" : "text/html",
          "css" : "text/css",
          "png" : "image/png",
          "jpg" : "image/jpeg",
          "jpeg" : "image/jpeg", 
          "ico" : "image/x-icon", 
        },
        split(".", file)[length(split(".", file)) - 1], # Extract the file extension from the file name
        "application/octet-stream" # Default if extension not found in map
      )
    }
  }
}

# Creates an s3 object resource for each file found in the locals object_map.
resource "aws_s3_object" "website_files" {
  for_each = local.object_map 
  bucket = aws_s3_bucket.bucket_config.id 
  key    = each.key                       
  source = each.value.source_path        
  content_type = each.value.content_type
  etag = filemd5(each.value.source_path)  # ile change detection 
}