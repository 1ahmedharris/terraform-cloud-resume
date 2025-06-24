# IAM Role GitHub Actions assumes
resource "aws_iam_role" "github_actions_resume_role" {
  name = "github-actions-resume-role"
  max_session_duration = 3600 

  # Trust Policy (assume_role_policy)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_username}/${var.github_repo_name}:*"
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# IAM Permissions Policy 
# Locals variable holds the JSON string of the permissions policy.
locals {
  github_actions_resume_permissions_json = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "CloudFront",
          "Effect": "Allow",
          "Action": [
            "cloudfront:CreateDistribution",
            "cloudfront:GetDistribution",
            "cloudfront:UpdateDistribution",
            "cloudfront:ListDistributions",
            "cloudfront:ListTagsForResource",
            "cloudfront:CreateOriginAccessControl",
            "cloudfront:GetOriginAccessControl",
            "cloudfront:UpdateOriginAccessControl",
            "cloudfront:ListOriginAccessControls",
            "cloudfront:GetCachePolicy",
            "acm:DescribeCertificate",
            "acm:ListCertificates",
            "cloudfront:CreateInvalidation"
          ],
          "Resource": "*" 
        },
        {
          "Sid": "S3BucketCreation",
          "Effect": "Allow",
          "Action": [
            "s3:CreateBucket",
            "s3:ListAllMyBuckets",
            "s3:GetBucketLocation"
          ],
          "Resource": "*" 
        },
        {
          "Sid": "S3BucketConfiguration",
          "Effect": "Allow",
          "Action": [
            "s3:GetBucketAcl",
            "s3:GetBucketPolicy",
            "s3:PutBucketPolicy",
            "s3:GetEncryptionConfiguration",
            "s3:PutEncryptionConfiguration",
            "s3:GetBucketVersioning",
            "s3:PutBucketVersioning",
            "s3:ListBucket"
          ],
          "Resource": "arn:aws:s3:::${var.s3_bucket}"
        },
        {
          "Sid": "S3ObjectManagement",
          "Effect": "Allow",
          "Action": [
            "s3:PutObject",
            "s3:GetObject"
          ],
          "Resource": "arn:aws:s3:::${var.s3_bucket}/*"
        },
        {
          "Sid": "STSCallerIdentity",
          "Effect": "Allow",
          "Action": "sts:GetCallerIdentity",
          "Resource": "*" 
        },
        {
          "Sid": "LambdaIAMGlobalActions",
          "Effect": "Allow",
          "Action": [
            "iam:CreateRole",
            "iam:ListPolicies",
            "iam:ListRoles"
          ],
          "Resource": "*" 
        },
        {
          "Sid": "LambdaRoleManagement",
          "Effect": "Allow",
          "Action": [
            "iam:GetRole",
            "iam:UpdateAssumeRolePolicy",
            "iam:PutRolePolicy",
            "iam:GetRolePolicy",
            "iam:AttachRolePolicy",
            "iam:ListAttachedRolePolicies"
          ],
          "Resource": "arn:aws:iam::${var.aws_account_id}:role/lamba-dynamodb-role"
        },
        {
          "Sid": "LambdaBasicExecutionPolicyRead",
          "Effect": "Allow",
          "Action": "iam:GetPolicy",
          "Resource": "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
        },
        {
          "Sid": "LambdaPassRole",
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": "arn:aws:iam::${var.aws_account_id}:role/lamba-dynamodb-role"
        },
        {
          "Sid": "LambdaFunctionManagement",
          "Effect": "Allow",
          "Action": [
            "lambda:CreateFunction",
            "lambda:GetFunction",
            "lambda:UpdateFunctionConfiguration",
            "lambda:UpdateFunctionCode",
            "lambda:ListFunctions",
            "lambda:AddPermission",
            "lambda:GetPolicy",
            "lambda:CreateFunctionUrlConfig",
            "lambda:GetFunctionUrlConfig",
            "lambda:UpdateFunctionUrlConfig",
            "lambda:ListFunctionUrlConfigs"
          ],
          "Resource": [
            "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.lambda_function}",
            "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.lambda_function}:*"
          ]
        },
        {
          "Sid": "CloudWatchLogsManagement",
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:DescribeLogGroups"
          ],
          "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.lambda_function}:*"
        },
        {
          "Sid": "DynamoDBTableManagement",
          "Effect": "Allow",
          "Action": [
            "dynamodb:CreateTable",
            "dynamodb:DescribeTable",
            "dynamodb:UpdateTable",
            "dynamodb:ListTables"
          ],
          "Resource": [
            "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/visitor-count-table",
            "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/visitor-count-table/*"
          ]
        },
        {
          "Sid": "Route53GlobalActions",
          "Effect": "Allow",
          "Action": [
            "route53:CreateHostedZone",
            "route53:ListHostedZones",
            "route53:GetChange"
          ],
          "Resource": "*" 
        },
        {
          "Sid": "Route53ZoneAndRecordManagement",
          "Effect": "Allow",
          "Action": [
            "route53:GetHostedZone",
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets"
          ],
          "Resource": [
            "arn:aws:route53:::hostedzone/${var.main_resume_hosted_zone}",
            "arn:aws:route53:::hostedzone/${var.devops_resume_hosted_zone}"
          ]
        },
        {
          "Sid": "S3RemoteBackend",
          "Effect": "Allow",
          "Action": [
            "s3:ListBucket",
            "s3:GetObject",
            "s3:PutObject"
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
            "dynamodb:DescribeTable"
          ],
          "Resource": "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.dynamodb_lock_table}"
        }
      ]
    }
  )
}

# Attach github_actions_iam_policy permissions policy to github_actions_resume_role
resource "aws_iam_role_policy" "github_actions_resume_policy" {
  name   = var.github_actions_iam_policy 
  role   = aws_iam_role.github_actions_resume_role.id 
  policy = local.github_actions_resume_permissions_json 
}