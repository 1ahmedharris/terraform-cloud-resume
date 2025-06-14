resource "aws_dynamodb_table" "visitor_count_table" {
  name         = "visitor-count-table"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  hash_key = "id"

  point_in_time_recovery {
    enabled = false
  }

  ttl {
    attribute_name = ""
    enabled        = false
  }
}

output "dynamodb_table_name_output" {
  value       = aws_dynamodb_table.visitor_count_table.name
  description = "The name of the DynamoDB visitor count table."
}

output "dynamodb_table_arn_output" {
  value       = aws_dynamodb_table.visitor_count_table.arn
  description = "The ARN of the DynamoDB visitor count table."
}