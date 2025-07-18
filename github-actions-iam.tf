resource "aws_iam_role" "github_actions_resume_role" {
  name = "github-actions-resume-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${var.aws_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org_name}/${var.github_repo_name}:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}




resource "aws_iam_policy" "github_actions_resume_policy" {
  name        = "github-actions-resume-policy"
  description = "Policy allowing GitHub Actions to provision infrastructure for cloud resume and backend"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      {
        Effect = "Allow",
        Action = [
          "iam:ListPolicies"
        ],
        Resource = "*"
      },

      {
        Effect = "Allow",
        Action = [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies"
        ],
        Resource = [
          "arn:aws:iam::${var.aws_id}:role/*"
        ]
      },

      {
        Effect = "Allow",
        Action = [
          "iam:ListAttachedRolePolicies"
        ],
        Resource = [
          "arn:aws:iam::${var.aws_id}:role/github-actions-resume-role",
          "arn:aws:iam::${var.aws_id}:role/lamba-dynamodb-role"
        ]
      },

      {
        Effect = "Allow",
        Action = [
          "iam:GetPolicy"
        ],
        Resource = [
          "arn:aws:iam::${var.aws_id}:policy/github-actions-resume-policy",
          "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
        ]
      },

      {
        Effect = "Allow",
        Action = [
          "cloudfront:ListTagsForResource"
        ],
        Resource = "arn:aws:cloudfront::${var.aws_id}:distribution/E11U5R2YIBF4OY"
      },

      # CloudFront permissions
      {
        Effect = "Allow",
        Action = [
          "cloudfront:UpdateDistribution",
          "cloudfront:GetDistribution",
          "cloudfront:CreateInvalidation",
          "cloudfront:ListCachePolicies",
          "cloudfront:GetDistributionConfig",
          "cloudfront:GetOriginAccessControl",
          "cloudfront:GetCachePolicy"
        ],
        Resource = "*"
      },

      # ACM
      {
        Effect = "Allow",
        Action = [
          "acm:DescribeCertificate"
        ],
        Resource = "${var.acm_certificate_arn}"
      },

      # WAFv2
      {
        Effect = "Allow",
        Action = [
          "wafv2:GetWebACL",
          "wafv2:ListWebACLs"
        ],
        Resource = "${var.cloudfront_web_acl_arn}"
      },

      {
        Effect = "Allow",
        Action = [
          "s3:ListAllMyBuckets"
        ],
        Resource = "*"
      },

      # S3 bucket permissions
      {
        Effect = "Allow",
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:GetBucketLocation",
          "s3:PutBucketPolicy",
          "s3:GetBucketPolicy",
          "s3:PutBucketVersioning",
          "s3:GetBucketVersioning",
          "s3:PutEncryptionConfiguration",
          "s3:GetEncryptionConfiguration"
        ],
        Resource = "arn:aws:s3:::${var.s3_bucket}"
      },

      # S3 object permissions
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::${var.s3_bucket}/*"
      },

      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::resume-remote-backend",
          "arn:aws:s3:::resume-remote-backend/*"
        ]
      },

      # Lambda permissions
      {
        Effect = "Allow",
        Action = [
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:InvokeFunction",
          "lambda:CreateFunctionUrlConfig",
          "lambda:UpdateFunctionUrlConfig",
          "lambda:GetFunctionUrlConfig"
        ],
        Resource = "*"
      },

      # Allow GitHub Actions to pass Lambda role
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = "arn:aws:iam::${var.aws_id}:role/lamba-dynamodb-role",
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = "lambda.amazonaws.com"
          }
        }
      },

      # Lambda dynamodb permissions
      {
        Effect = "Allow",
        Action = [
          "dynamodb:UpdateTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DescribeTable",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DeleteItem"
        ],
        Resource = "arn:aws:dynamodb:${var.aws_region}:${var.aws_id}:table/${var.visitor_count_table}"
      },

      # Route 53 permissions
      {
        Effect = "Allow",
        Action = [
          "route53:CreateHostedZone",
          "route53:DeleteHostedZone",
          "route53:GetHostedZone"
        ],
        Resource = "*"
      },

      {
        Effect = "Allow",
        Action = [
          "route53:ListTagsForResource"
        ],
        Resource = [
          "arn:aws:route53:::hostedzone/Z01018062M98VOF9SUSIM",
          "arn:aws:route53:::hostedzone/Z056701228ISTWPXZ137W"
        ]
      },

      {
        Effect = "Allow",
        Action = [
          "logs:DescribeLogGroups"
        ],
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_id}:log-group:*"
      },

      {
        Effect = "Allow",
        Action = [
          "logs:ListTagsForResource"
        ],
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_id}:log-group:/aws/lambda/aitc-lamba-function"
      },

      # CloudWatch Logs for Lambda
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_resume_policy_attachment" {
  role       = aws_iam_role.github_actions_resume_role.name
  policy_arn = aws_iam_policy.github_actions_resume_policy.arn
}


