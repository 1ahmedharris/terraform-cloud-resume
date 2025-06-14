

variable "website_content_path" {
  description = "Local file system path to the root directory of website content."
  type        = string
}


variable "acm_certificate_arn" {
  description = "The ARN of ACM certificate for CloudFront distribution's custom domain."
  type        = string
}


variable "cloudfront_web_acl_arn" {
  description = "The ARN of AWS WAF Web ACL to associate with CloudFront distribution."
  type        = string
}


variable "cloudfront_aliases" {
  description = "List of all domain name aliases used by the CloudFront distribution."
  type        = list(string)
}


variable "cloudfront_restriction_locations" {
  description = "List of country codes for geo-restriction."
  type        = list(string)
}


variable "cloudfront_restriction_type" {
  description = "Type of geo-restriction."
  type        = string
}


variable "lambda_function" {
  description = "Visitor counter Lambda function."
  type        = string
}


variable "lambda_counter_zip" {
  description = "Visitor counter Lambda file path."
  type        = string
}


variable "views_count" {
  description = "Count for visitor-count-table/site views."
  type        = string
}

variable "count_id" {
  description = "Id attribute for the counter item in the visitor-count-table."
  type        = string
}