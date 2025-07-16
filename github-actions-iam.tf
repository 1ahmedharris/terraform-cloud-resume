# IAM role github actions ci/cd workflow assumes
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

# Permissions for github-actions-resume-policy
locals {
  github_actions_resume_permissions_json = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        # General Read Actions (for overall AWS environment visibility)
        {
          "Sid": "GeneralReadActions",
          "Effect": "Allow",
          "Action": [
            "sts:GetCallerIdentity",
            "iam:ListRoles",
            "iam:ListPolicies",
            "iam:ListAttachedRolePolicies",
            "iam:ListRolePolicies",
            "iam:ListPolicyVersions",
            "iam:GetRole",
            "iam:GetPolicy",
            "iam:GetPolicyVersion",
            "lambda:ListFunctions",
            "lambda:GetAccountSettings",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "dynamodb:ListTables",
            "route53:ListHostedZones",
            "cloudfront:ListDistributions",
            "cloudfront:ListOriginAccessControls",
            "cloudfront:ListCachePolicies",
            "cloudfront:ListInvalidations",
            "acm:ListCertificates",
          ],
          "Resource": "*" # Broad for common list/get operations
        },
        # IAM Management for GitHub Actions Role and related resources
        {
          "Sid": "IAMRoleAndPolicyManagement",
          "Effect": "Allow",
          "Action": [
            "iam:AttachRolePolicy",
            "iam:DetachRolePolicy",
            "iam:PutRolePolicy",
            "iam:DeleteRolePolicy",
            "iam:UpdateAssumeRolePolicy",
            "iam:PassRole", # Required for Lambda to assume its role
            "iam:CreatePolicyVersion",
            "iam:DeletePolicyVersion",
            "iam:SetDefaultPolicyVersion",
          ],
          "Resource": [
            "arn:aws:iam::${var.aws_id}:role/${aws_iam_role.github_actions_resume_role.name}",
            "arn:aws:iam::${var.aws_id}:policy/${var.github_actions_iam_policy}",
            "arn:aws:iam::${var.aws_id}:role/lamba-dynamodb-role", # Specific Lambda execution role
          ]
        },
        # Terraform State Backend S3 Operations
        {
          "Sid": "S3RemoteBackend",
          "Effect": "Allow",
          "Action": [
            "s3:ListBucket",
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            # Include Get/Put for all essential bucket configurations for the backend
            "s3:GetBucketAcl",
            "s3:PutBucketAcl",
            "s3:GetBucketPolicy",
            "s3:PutBucketPolicy",
            "s3:GetBucketCORS",
            "s3:GetBucketLocation",
            "s3:GetBucketVersioning",
            "s3:PutBucketVersioning",
            "s3:GetBucketWebsite",
            "s3:PutBucketWebsite",
            "s3:GetBucketRequestPayment",
            "s3:PutBucketRequestPayment",
            "s3:GetAccelerateConfiguration",
            "s3:PutAccelerateConfiguration",
            "s3:GetBucketLogging",
            "s3:PutBucketLogging",
            "s3:GetBucketTagging",
            "s3:PutBucketTagging",
            "s3:GetBucketPublicAccessBlock",
            "s3:PutBucketPublicAccessBlock",
            "s3:GetEncryptionConfiguration",
            "s3:PutEncryptionConfiguration",
          ],
          "Resource": [
            "arn:aws:s3:::${var.s3_remote_backend}",
            "arn:aws:s3:::${var.s3_remote_backend}/*" # For objects within the backend bucket
          ]
        },
        # DynamoDB Lock Table Operations
        {
          "Sid": "DynamoDBLockTable",
          "Effect": "Allow",
          "Action": [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:DeleteItem",
            "dynamodb:DescribeTable",
            "dynamodb:UpdateItem", # For lock acquisition/release
            "dynamodb:UpdateTimeToLive",
            "dynamodb:ListTagsOfResource"
          ],
          "Resource": "arn:aws:dynamodb:${var.aws_region}:${var.aws_id}:table/${var.dynamodb_lock_table}"
        },
        # S3 Website Bucket Management
        {
          "Sid": "S3WebsiteBucketManagement",
          "Effect": "Allow",
          "Action": [
            "s3:CreateBucket", # If your TF creates the bucket
            "s3:DeleteBucket", # If your TF deletes the bucket
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
            "s3:GetBucketLogging",
            "s3:PutBucketLogging",
            "s3:ListBucket" # For specific bucket
          ],
          "Resource": "arn:aws:s3:::${var.s3_bucket}"
        },
        # S3 Website Object Access
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
        # Lambda Function Management
        {
          "Sid": "LambdaFunctionManagement",
          "Effect": "Allow",
          "Action": [
            "lambda:CreateFunction",
            "lambda:GetFunction",
            "lambda:UpdateFunctionConfiguration",
            "lambda:UpdateFunctionCode",
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
            "lambda:GetFunctionCodeSigningConfig",
          ],
          "Resource": [
            "arn:aws:lambda:${var.aws_region}:${var.aws_id}:function:${var.lambda_function}",
            "arn:aws:lambda:${var.aws_region}:${var.aws_id}:function:${var.lambda_function}:*",
          ]
        },
        # CloudWatch Logs Management
        {
          "Sid": "CloudWatchLogsManagement",
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:DeleteLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:ListTagsForResource",
            "logs:TagResource",
            "logs:UntagResource",
          ],
          "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_id}:log-group:*"
        },
        # DynamoDB Table Management (for visitor-count-table)
        {
          "Sid": "DynamoDBTableManagement",
          "Effect": "Allow",
          "Action": [
            "dynamodb:CreateTable",
            "dynamodb:DescribeTable",
            "dynamodb:UpdateTable",
            "dynamodb:DeleteTable",
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
        # Route53 Resources Management
        {
          "Sid": "Route53Management",
          "Effect": "Allow",
          "Action": [
            "route53:CreateHostedZone",
            "route53:DeleteHostedZone",
            "route53:GetHostedZone",
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets",
            "route53:GetChange",
            "route53:ListTagsForResource",
            "route53:TagResource",
            "route53:UntagResource",
          ],
          "Resource": [
            "arn:aws:route53:::hostedzone/*", # For global actions and specific zones
            "arn:aws:route53:::hostedzone/${var.main_resume_hosted_zone}",
            "arn:aws:route53:::hostedzone/${var.devops_resume_hosted_zone}",
          ]
        },
        # ACM Cert Read
        {
          "Sid": "ACMRead",
          "Effect": "Allow",
          "Action": [
            "acm:DescribeCertificate",
          ],
          "Resource": "*" # ACM resources are global
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
