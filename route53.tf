#Public hosted zone ahmedharrisresume.com
resource "aws_route53_zone" "www_resume_zone" {
  name    = "ahmedharrisresume.com"
  zone_id =  "Z01018062M98VOF9SUSIM"
}

# Alias record for root domain ahmedharrisresume.com pointing to CloudFront
resource "aws_route53_record" "www_resume_root_alias" {
  zone_id                = aws_route53_zone.www_resume_zone.zone_id
  name                   = "ahmedharrisresume.com"
  type                   = "A"
  alias {
    name                   = [aws_cloudfront_distribution.cloudfront_cdn.domain_name]
    zone_id                = [aws_cloudfront_distribution.cloudfront_cdn.hosted_zone_id]
    evaluate_target_health = false
  }
}

# Alias record for subdomain www.ahmedharrisresume.com pointing to CloudFront
resource "aws_route53_record" "www_resume_subdomain_alias" {
  zone_id                = aws_route53_zone.www_resume_zone.zone_id
  name                   = "www.ahmedharrisresume.com" 
  type                   = "A"
  alias {
    name                   = [aws_cloudfront_distribution.cloudfront_cdn.domain_name]
    zone_id                = [aws_cloudfront_distribution.cloudfront_cdn.hosted_zone_id]
    evaluate_target_health = false
  }
}

#Public hosted zone ahmedharrisdevops.com
resource "aws_route53_zone" "www_devops_zone" {
  name = "ahmedharrisdevops.com"
}

# Alias record for root domain ahmedharrisdevops.com pointing to CloudFront
resource "aws_route53_record" "www_devops_root_alias" {
  zone_id                = aws_route53_zone.www_devops_zone.zone_id
  name                   = "ahmedharrisdevops.com"
  type                   = "A"
  alias {
    name                   = [aws_cloudfront_distribution.cloudfront_cdn.domain_name]
    zone_id                = [aws_cloudfront_distribution.cloudfront_cdn.hosted_zone_id]
    evaluate_target_health = false
  }
}

# Alias record for subdomain www.ahmedharrisresume.com pointing to CloudFront
resource "aws_route53_record" "www_devops_subdomain_alias" {
  zone_id                = aws_route53_zone.www_devops_zone.zone_id
  name                   = "www.ahmedharrisdevops.com" # This is the www subdomain name
  type                   = "A"
  alias {
    name                   = [aws_cloudfront_distribution.cloudfront_cdn.domain_name]
    zone_id                = [aws_cloudfront_distribution.cloudfront_cdn.hosted_zone_id]
    evaluate_target_health = false
  }
}

