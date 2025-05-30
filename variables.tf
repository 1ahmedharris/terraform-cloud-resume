# variables.tf

variable "website_content_path" {
  description = "The local file system path to the root of your website content."
  type        = string
}


variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for the CloudFront distribution's custom domain."
  type        = string
}


variable "cloudfront_aliases" {
  description = "List of domain names for the CloudFront distribution."
  type        = list(string)
}


variable "cloudfront_web_acl_arn" {
  description = "The ARN of an AWS WAF Web ACL to associate with the CloudFront distribution. Set to null if not used."
  type        = string
}


variable "cloudfront_restriction_locations" {
  description = "A list of country codes (ISO 3166-1 alpha-2) for geo-restriction."
  type        = list(string)
}


variable "cloudfront_restriction_type" {
  description = "The type of geo-restriction: 'none', 'whitelist', or 'blacklist'."
  type        = string
}


