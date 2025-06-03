

# Data source to reference your existing Lambda Execution Role
data "aws_iam_role" "lambda_counter_role" {
  name = "lamba-dynamodb-role" # <--- IMPORTANT: Replace with the actual name of your Lambda's IAM role from AWS!
}



resource "aws_lambda_function" "visitor_counter_api" {
  function_name = var.lambda_function
  filename         = var.lambda_counter_zip # Example path
  source_code_hash = filebase64sha256(var.lambda_counter_zip)
  handler       = "lambda_function.lambda_handler" # Assumes your Python code has a main.py and handler function
  runtime       = "python3.13"
  timeout       = 5 # seconds
  memory_size   = 128 # MB, adjust as needed
  role = data.aws_iam_role.lambda_counter_role.arn

  # Environment variable for your DynamoDB table name
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.visitor_count_table.name # Assumes this resource exists
    }
  }

  # Ensure the Lambda function creates its default log group
  depends_on = [
    aws_cloudwatch_log_group.visitor_counter_api_log_group
  ]
}
