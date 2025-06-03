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
              "AWS:SourceArn" = "arn:aws:cloudfront::941377150270:distribution/E11U5R2YIBF4OY" # Hardcoded CloudFront ARN
            }
          }
        },
      ]
    }
  )
}


# Define local filepath values to iterate through
# Discover ALL files recursively within the specified website_content_path
# (**) matches all files and all subdirectories.
locals {
  files = fileset(var.website_content_path, "**/*")
  # Create map where keys are the S3 object keys
  object_map = {
    for file in local.files :
    file => {
      source_path  = "${var.website_content_path}/${file}" # Full local path to the file
      content_type = lookup(
        { # Map common file extensions to their MIME types
          "html" : "text/html",
          "css" : "text/css",
          "png" : "image/png",
          "jpg" : "image/jpeg",
          "jpeg" : "image/jpeg", 
          "ico" : "image/x-icon", 
        },
        # Extract the file extension from the file name
        split(".", file)[length(split(".", file)) - 1],
        "application/octet-stream" # Default if extension not found in map
      )
    }
  }
}


# Create an aws_s3_object resource for each file found in the object_map.
resource "aws_s3_object" "website_files" {
  for_each = local.object_map 
  bucket = aws_s3_bucket.bucket_config.id 
  key    = each.key                       
  source = each.value.source_path        
  content_type = each.value.content_type
  etag = filemd5(each.value.source_path)  # Change detection and CloudFront
}