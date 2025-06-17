#Public hosted zone ahmedharrisresume.com
resource "aws_route53_zone" "www_resume_zone" {
  name    = var.main_resume_domain_name
}

# Alias record for root domain ahmedharrisresume.com pointing to CloudFront
resource "aws_route53_record" "www_resume_root_alias" {
  zone_id                = aws_route53_zone.www_resume_zone.zone_id
  name                   = var.main_resume_domain_name
  type                   = "A"
  alias {
    name                   = aws_cloudfront_distribution.cloudfront_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# Alias record for subdomain www.ahmedharrisresume.com pointing to CloudFront
resource "aws_route53_record" "www_resume_subdomain_alias" {
  zone_id                = aws_route53_zone.www_resume_zone.zone_id
  name                   = var.main_resume_subdomain
  type                   = "A"
  alias {
    name                   = aws_cloudfront_distribution.cloudfront_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

#Public hosted zone ahmedharrisdevops.com
resource "aws_route53_zone" "www_devops_zone" {
  name = var.devops_resume_domain_name
}

# Alias record for root domain ahmedharrisdevops.com pointing to CloudFront
resource "aws_route53_record" "www_devops_root_alias" {
  zone_id                = aws_route53_zone.www_devops_zone.zone_id
  name                   = var.devops_resume_domain_name
  type                   = "A"
  alias {
    name                   = aws_cloudfront_distribution.cloudfront_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# Alias record for subdomain www.ahmedharrisdevops.com pointing to CloudFront
resource "aws_route53_record" "www_devops_subdomain_alias" {
  zone_id                = aws_route53_zone.www_devops_zone.zone_id
  name                   = var.devops_resume_subdomain
  type                   = "A"
  alias {
    name                   = aws_cloudfront_distribution.cloudfront_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

