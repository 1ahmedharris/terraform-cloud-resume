variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "aws_id" {
  description = "AWS id"
  type        = string
}

variable "s3_bucket" {
  description = "Name of s3 bucket."
  type        = string
}

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

variable "main_resume_domain_name" {
  description = "ahmedharrisresume.com"
  type        = string 
}

variable "main_resume_subdomain" {
  description = "www.ahmedharrisresume.com"
  type        = string
}

variable "devops_resume_domain_name" {
  description = "ahmedharrisdevops.com"
  type        = string
}

variable "devops_resume_subdomain" {
  description = "www.ahmedharrisdevops.com"
  type        = string
}

variable "main_resume_hosted_zone" {
  description = "www.ahmedharrisresume.com hosted zone id"
  type        = string
}

variable "devops_resume_hosted_zone" {
  description = "www.ahmedharrisdevops.com hosted zone id"
  type        = string
}

variable "s3_remote_backend" {
  description = "Name of remote backend S3 bucket used for Terraform remote state."
  type        = string
  default     = "resume-remote-backend" 
}

variable "dynamodb_lock_table" {
  description = "Name of DynamoDB table used for Terraform state locking."
  type        = string
  default     = "resume-state-lock-table" 
}

variable "github_org_name" {
  description = "GitHub username."
  type        = string
}

variable "github_repo_name" {
  description = "GitHub repository name."
  type        = string
}

variable "github_actions_iam_policy" {
  description = "Name of IAM policy for GitHub Actions."
  type        = string
  default     = "github-actions-resume-policy"
}




