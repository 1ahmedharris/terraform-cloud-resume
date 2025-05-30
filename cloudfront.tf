# cloudfront.tf

locals {
  s3_origin_id = "aitc-s3-origin" 
  # Collect all the ETags from the S3 objects managed by Terraform.
  # s3_objects_etags_list = [for obj in aws_s3_object.website_files : obj.etag]
  # Create a unique hash from the sorted list of ETags.
  # cloudfront_invalidation_hash = sha1(join("", sort(local.s3_objects_etags_list)))
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
  name                              = "cnd-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cloudfront_distro" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "site origin"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  aliases             = var.cloudfront_aliases
  web_acl_id          = var.cloudfront_web_acl_arn 
  wait_for_deployment = true
  http_version        = "http2"

  origin {
    domain_name              = aws_s3_bucket.bucket_config.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id
    origin_id                = local.s3_origin_id 
    connection_attempts      = 3
    connection_timeout       = 7
  }

  default_cache_behavior {
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    target_origin_id           = local.s3_origin_id
    allowed_methods            = ["GET", "HEAD"] 
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    viewer_protocol_policy     = "https-only"
  }

  restrictions {
    geo_restriction {
      locations        = var.cloudfront_restriction_locations
      restriction_type = var.cloudfront_restriction_type
    }
  }

  viewer_certificate {
    acm_certificate_arn        = var.acm_certificate_arn
    minimum_protocol_version   = "TLSv1.2_2021"
    ssl_support_method         = "sni-only"
  }

}


# resource "aws_cloudfront_invalidation" "s3_content_invalidation" {
#  distribution_id = aws_cloudfront_distribution.cloudfront_distro.id
#  paths = ["/*"]
#  # caller_reference must change for CloudFront to create a new invalidation.
#  caller_reference = local.cloudfront_invalidation_hash
  # Invalidation runs AFTER the S3 objects have been updated.
#  depends_on = [
#    aws_s3_object.website_files
#  ]
#}