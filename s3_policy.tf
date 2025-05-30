

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