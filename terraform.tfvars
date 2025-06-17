website_content_path        = "C:/Users/aitc1/OneDrive/Desktop/aitc/web-projects/test-site"
acm_certificate_arn         = "arn:aws:acm:us-east-1:941377150270:certificate/7a4f2333-db72-487d-9d6d-9460d4c89d82"
cloudfront_web_acl_arn      = "arn:aws:wafv2:us-east-1:941377150270:global/webacl/CreatedByCloudFront-e5fddf7d-adfe-47d9-ac30-9c4f2c4f22f3/257fcf48-1155-4387-b2ff-7ca6be751f8e"
cloudfront_restriction_type = "blacklist"
lambda_function             = "aitc-lamba-function"
lambda_counter_zip          = "build/lambda_counter.zip"
main_resume_domain_name     = "ahmedharrisresume.com"
main_resume_subdomain       = "www.ahmedharrisresume.com"
devops_resume_domain_name   = "ahmedharrisdevops.com"
devops_resume_subdomain     = "www.ahmedharrisdevops.com"
cloudfront_restriction_locations = [
  "AL", "AM", "AR", "AT", "AU", "BE", "BG",
  "BR", "BY", "CH", "CI", "CN", "CY", "CZ",
  "DE", "DK", "EE", "EG", "ES", "ET", "FI", 
  "FJ", "FR", "GB", "GE", "GH", "GM", "GR",
  "HK", "HR", "HU", "ID", "IE", "IL", "IR",
  "IT", "JO", "JP", "KE", "KG", "KP", "KR",
  "KZ", "LT", "LU", "LV", "MA", "MK", "ML",
  "MS", "MY", "NG", "NL", "NO", "PH", "PL",
  "PT", "RO", "RS", "RU", "SE", "SG", "SY",
  "TH", "TR", "TW", "TZ", "UA", "UG", "UZ", 
  "VE", "VN", "ZA"
]

cloudfront_aliases = [
  "ahmedharrisdevops.com",
  "ahmedharrisresume.com",
  "www.ahmedharrisdevops.com",
  "www.ahmedharrisresume.com"
]


