# s3_content.tf

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
  key    = each.key                       # S3 object key 
  source = each.value.source_path         # Local path
  content_type = each.value.content_type
  etag = filemd5(each.value.source_path)  # Change detection and CloudFront
}