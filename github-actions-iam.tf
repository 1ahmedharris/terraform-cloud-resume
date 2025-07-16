# Github actions IAM role ci/cd workflow permissiond v1.2
resource "aws_iam_role" "github_actions_resume_role" {
  name                 = "github-actions-resume-role"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org_name}/${var.github_repo_name}:*"
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# github-actions-resume-policy Permissions 
locals {
  github_actions_resume_permissions_json = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "STSGetCallerIdentity",
          "Effect": "Allow",
          "Action": "sts:GetCallerIdentity",
          "Resource": "*"
        },

        # Terraform IAM Role and Policy Permissions 
        {
          "Sid": "IAMSelfManagement",
          "Effect": "Allow",
          "Action": [
            "iam:GetRole",
            "iam:UpdateAssumeRolePolicy",
            "iam:PutRolePolicy",
            "iam:GetRolePolicy",
            "iam:DeleteRolePolicy", 
            "iam:AttachRolePolicy",
            "iam:DetachRolePolicy",
            "iam:GetPolicy",
            "iam:GetPolicyVersion",
            "iam:ListAttachedRolePolicies",
            "iam:ListRolePolicies",
            "iam:ListPolicies", 
            "iam:ListRoles",   
            "iam:PassRole",    
            "iam:CreatePolicy", 
            "iam:DeletePolicy",
          ],
          "Resource": [
            "arn:aws:iam::${var.aws_id}:role/${aws_iam_role.github_actions_resume_role.name}", 
            "arn:aws:iam::${var.aws_id}:policy/${var.github_actions_iam_policy}", 
            "arn:aws:iam::${var.aws_id}:role/lamba-dynamodb-role", 
            "arn:aws:iam::${var.aws_id}:role/*", 
            "arn:aws:iam::${var.aws_id}:policy/*", 
            "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
            "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess", 
          ]
        },

        # S3 Remote Backend & DynamoDB State Locking Permissions
        {
          "Sid": "S3RemoteBackend",
          "Effect": "Allow",
          "Action": [
            "s3:ListBucket",
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:GetBucketAcl",
            "s3:GetBucketPolicy",
            "s3:PutBucketPolicy",
            "s3:GetBucketCORS",
            "s3:GetBucketLocation",
            "s3:GetBucketVersioning",
            "s3:PutBucketVersioning",
            "s3:GetBucketWebsite",        
            "s3:GetBucketRequestPayment", 
          ],
          "Resource": [
            "arn:aws:s3:::${var.s3_remote_backend}",
            "arn:aws:s3:::${var.s3_remote_backend}/*"
          ]
        },
        {
          "Sid": "DynamoDBLockTable",
          "Effect": "Allow",
          "Action": [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:DeleteItem",
            "dynamodb:DescribeTable",
            "dynamodb:DescribeContinuousBackups",
            "dynamodb:DescribeTimeToLive",
            "dynamodb:ListTagsOfResource"
          ],
          "Resource": "arn:aws:dynamodb:${var.aws_region}:${var.aws_id}:table/${var.dynamodb_lock_table}"
        },

        # S3 Permissions
        {
          "Sid": "S3GlobalBucketActions",
          "Effect": "Allow",
          "Action": [
            "s3:CreateBucket",
            "s3:ListAllMyBuckets",
            "s3:GetBucketLocation"
          ],
          "Resource": "*" 
        },
        {
          "Sid": "S3WebsiteBucketConfig",
          "Effect": "Allow",
          "Action": [
            "s3:GetBucketAcl",
            "s3:PutBucketAcl",
            "s3:GetBucketPolicy",
            "s3:PutBucketPolicy",
            "s3:DeleteBucketPolicy",
            "s3:GetEncryptionConfiguration",
            "s3:PutEncryptionConfiguration",
            "s3:GetBucketVersioning",
            "s3:PutBucketVersioning",
            "s3:GetBucketCORS",
            "s3:PutBucketCORS",
            "s3:DeleteBucketCORS",
            "s3:GetBucketWebsite",
            "s3:PutBucketWebsite",
            "s3:DeleteBucketWebsite",
            "s3:GetAccelerateConfiguration",
            "s3:PutAccelerateConfiguration",
            "s3:GetBucketRequestPayment", 
            "s3:PutBucketRequestPayment",
            "s3:GetBucketPublicAccessBlock",
            "s3:PutBucketPublicAccessBlock",
            "s3:DeleteBucketPublicAccessBlock",
            "s3:GetBucketTagging",
            "s3:PutBucketTagging",
            "s3:DeleteBucketTagging",
            "s3:GetBucketOwnershipControls",
            "s3:PutBucketOwnershipControls",
            "s3:DeleteBucketOwnershipControls",
            "s3:PutLifecycleConfiguration",
            "s3:GetLifecycleConfiguration",
            "s3:DeleteLifecycleConfiguration",
            "s3:ListBucket", 
            "s3:DeleteBucket", 
          ],
          "Resource": "arn:aws:s3:::${var.s3_bucket}"
        },
        {
          "Sid": "S3WebsiteObjectAccess",
          "Effect": "Allow",
          "Action": [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:ListMultipartUploadParts",
            "s3:AbortMultipartUpload",
            "s3:GetObjectVersion",
          ],
          "Resource": "arn:aws:s3:::${var.s3_bucket}/*"
        },

        # Cloudfront Permissions 
        {
          "Sid": "CloudFrontManagement",
          "Effect": "Allow",
          "Action": [
            "cloudfront:CreateDistribution",
            "cloudfront:GetDistribution",
            "cloudfront:GetDistributionConfig",
            "cloudfront:UpdateDistribution",
            "cloudfront:DeleteDistribution",
            "cloudfront:ListDistributions",
            "cloudfront:CreateOriginAccessControl",
            "cloudfront:GetOriginAccessControl",
            "cloudfront:UpdateOriginAccessControl",
            "cloudfront:DeleteOriginAccessControl",
            "cloudfront:ListOriginAccessControls",
            "cloudfront:GetCachePolicy",
            "cloudfront:ListCachePolicies",
            "cloudfront:CreateInvalidation",
            "cloudfront:GetInvalidation", 
            "cloudfront:ListInvalidations",
            "cloudfront:ListTagsForResource",
            "cloudfront:TagResource",
            "cloudfront:UntagResource",
          ],
          "Resource": "*" 
        },
        {
          "Sid": "ACMRead",
          "Effect": "Allow",
          "Action": [
            "acm:DescribeCertificate",
            "acm:ListCertificates"
          ],
          "Resource": "*" 
        },

        # Lambda Permissions 
        {
          "Sid": "LambdaFunctionManagement",
          "Effect": "Allow",
          "Action": [
            "lambda:CreateFunction",
            "lambda:GetFunction",
            "lambda:UpdateFunctionConfiguration",
            "lambda:UpdateFunctionCode",
            "lambda:ListFunctions",
            "lambda:DeleteFunction",
            "lambda:ListVersionsByFunction", 
            "lambda:PublishVersion",
            "lambda:DeleteFunctionConcurrency",
            "lambda:GetFunctionConcurrency",
            "lambda:PutFunctionConcurrency",
            "lambda:CreateFunctionUrlConfig",
            "lambda:GetFunctionUrlConfig",
            "lambda:UpdateFunctionUrlConfig",
            "lambda:DeleteFunctionUrlConfig",
            "lambda:ListFunctionUrlConfigs",
            "lambda:AddPermission",
            "lambda:RemovePermission",
            "lambda:GetPolicy",
            "lambda:InvokeFunction",
            "lambda:GetAlias",
            "lambda:CreateAlias",
            "lambda:UpdateAlias",
            "lambda:DeleteAlias",
            "lambda:ListAliases",
            "lambda:TagResource",
            "lambda:UntagResource",
          ],
          "Resource": [
            "arn:aws:lambda:${var.aws_region}:${var.aws_id}:function:${var.lambda_function}",
            "arn:aws:lambda:${var.aws_region}:${var.aws_id}:function:${var.lambda_function}:*", 
          ]
        },

        # Cloudwatch Permissions
        {
          "Sid": "CloudWatchLogsManagement",
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:DescribeLogGroups",
            "logs:DeleteLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:ListTagsForResource",
            "logs:TagResource",
            "logs:UntagResource",
          ],
          "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_id}:log-group:*"
        },

        # DynamoDB Permissions
        {
          "Sid": "DynamoDBTableManagement",
          "Effect": "Allow",
          "Action": [
            "dynamodb:CreateTable",
            "dynamodb:DescribeTable",
            "dynamodb:UpdateTable",
            "dynamodb:DeleteTable",
            "dynamodb:ListTables",
            "dynamodb:DescribeContinuousBackups",
            "dynamodb:UpdateTimeToLive",
            "dynamodb:DescribeTimeToLive",
            "dynamodb:UpdateContinuousBackups",
            "dynamodb:ListTagsOfResource",
            "dynamodb:TagResource",
            "dynamodb:UntagResource",
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
          ],
          "Resource": [
            "arn:aws:dynamodb:${var.aws_region}:${var.aws_id}:table/visitor-count-table",
            "arn:aws:dynamodb:${var.aws_region}:${var.aws_id}:table/visitor-count-table/*" 
          ]
        },

        # Route53 Permissions
        {
          "Sid": "Route53Management",
          "Effect": "Allow",
          "Action": [
            "route53:CreateHostedZone",
            "route53:DeleteHostedZone",
            "route53:ListHostedZones",
            "route53:GetHostedZone",
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets",
            "route53:GetChange",
            "route53:ListTagsForResource",
            "route53:TagResource",
            "route53:UntagResource",
          ],
          "Resource": [
            "arn:aws:route53:::hostedzone/*",
            "arn:aws:route53:::hostedzone/${var.main_resume_hosted_zone}",
            "arn:aws:route53:::hostedzone/${var.devops_resume_hosted_zone}",
          ]
        }
      ]
    }
  )
}

resource "aws_iam_policy" "github_actions_resume_policy" {
  name   = var.github_actions_iam_policy
  policy = local.github_actions_resume_permissions_json
}

resource "aws_iam_role_policy_attachment" "github_actions_policy_attachment" {
  role       = aws_iam_role.github_actions_resume_role.name
  policy_arn = aws_iam_policy.github_actions_resume_policy.arn
}
