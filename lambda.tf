data "aws_iam_policy" "lambda_basic_execution_policy" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "lambda_dynamodb_role" {
  name = "lamba-dynamodb-role"
  
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_counter_policy" {
  name = "visitor-counter-policy" 
  role = aws_iam_role.lambda_dynamodb_role.id 

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ],
        Resource = [aws_dynamodb_table.visitor_count_table.arn]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role_policy_attachment" {
  role       = aws_iam_role.lambda_dynamodb_role.id 
  policy_arn = data.aws_iam_policy.lambda_basic_execution_policy.arn
}

resource "aws_cloudwatch_log_group" "lambda_counter_api_log_group" {
  name              = "/aws/lambda/aitc-lamba-function" 
  retention_in_days = 30                             
}

resource "aws_lambda_function" "lambda_counter_api" {
  function_name    = var.lambda_function
  filename         = var.lambda_counter_zip
  source_code_hash = filebase64sha256(var.lambda_counter_zip)
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_dynamodb_role.arn
  runtime          = "python3.13"
  timeout          = 5 
  memory_size      = 128 
  
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.visitor_count_table.name 
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_counter_api_log_group,
    aws_iam_role.lambda_dynamodb_role,
    aws_iam_role_policy.lambda_counter_policy,
    aws_iam_role_policy_attachment.lambda_execution_role_policy_attachment,
  ]
}

resource "aws_lambda_permission" "allow_function_url_invocation" {
  action        = "lambda:InvokeFunctionUrl"
  function_name = aws_lambda_function.lambda_counter_api.function_name
  principal     = "*" 
  statement_id  = "FunctionURLAllowPublicAccess" 
  depends_on = [
    aws_lambda_function_url.lambda_counter_url
  ]
}

resource "aws_lambda_function_url" "lambda_counter_url" {
  function_name      = aws_lambda_function.lambda_counter_api.function_name
  authorization_type = "NONE" 
  invoke_mode = "BUFFERED"

  cors {
    allow_credentials = true
    # Allows requests from CloudFront distribution domain
    allow_origins     = ["https://${aws_cloudfront_distribution.cloudfront_distro.domain_name}"] 
    allow_methods     = ["GET", "POST", "OPTIONS"]
    allow_headers     = ["Content-Type"] # Add X-Api-Key for API key check or for IAM "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"
    expose_headers    = []
    max_age           = 86400
  }
}

output "lambda_counter_url_output" {
  value       = aws_lambda_function_url.lambda_counter_url.function_url
  description = "The URL endpoint for the visitor counter Lambda function."
}
