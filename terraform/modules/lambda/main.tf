# Add provider configuration at the top
provider "aws" {
  alias                       = "lambda"
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    lambda = "http://localhost:4566"
    iam    = "http://localhost:4566"
  }
}

# IAM Role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "frontend-discovery-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Add validation for Lambda source directories
locals {
  admin_api_dir = "${path.module}/../../../infrastructure/lambda/adminApi"
  consumer_api_dir = "${path.module}/../../../infrastructure/lambda/consumerApi"
  stream_dir = "${path.module}/../../../infrastructure/lambda/stream"
}

resource "null_resource" "check_lambda_sources" {
  provisioner "local-exec" {
    command = <<EOF
      if [ ! -d "${local.admin_api_dir}" ]; then echo "Admin API Lambda source directory not found at ${local.admin_api_dir}" && exit 1; fi
      if [ ! -d "${local.consumer_api_dir}" ]; then echo "Consumer API Lambda source directory not found at ${local.consumer_api_dir}" && exit 1; fi
      if [ ! -d "${local.stream_dir}" ]; then echo "Stream Lambda source directory not found at ${local.stream_dir}" && exit 1; fi
    EOF
  }
}

# Package Lambda functions
data "archive_file" "admin_api" {
  depends_on = [null_resource.check_lambda_sources]
  type        = "zip"
  source_dir  = local.admin_api_dir
  output_path = "${local.admin_api_dir}/app.zip"
  excludes    = ["app.zip"]
}

data "archive_file" "consumer_api" {
  type        = "zip"
  source_dir  = local.consumer_api_dir
  output_path = "${local.consumer_api_dir}/app.zip"
  excludes    = ["app.zip"]
}

data "archive_file" "stream_processor" {
  type        = "zip"
  source_dir  = local.stream_dir
  output_path = "${local.stream_dir}/app.zip"
  excludes    = ["app.zip"]
}

# Add logging for Lambda creation
resource "null_resource" "debug_lambda_creation" {
  provisioner "local-exec" {
    command = <<EOF
      echo "Debugging Lambda creation..."
      echo "Admin API source dir: ${local.admin_api_dir}"
      echo "Admin API zip file: ${data.archive_file.admin_api.output_path}"
      echo "Admin API hash: ${data.archive_file.admin_api.output_base64sha256}"
      ls -la ${local.admin_api_dir}
    EOF
  }
}

# Admin API Lambda
resource "aws_lambda_function" "admin_api" {
  filename         = data.archive_file.admin_api.output_path
  function_name    = "admin-api"
  role            = aws_iam_role.lambda_role.arn
  handler         = "app.handler"
  runtime         = "nodejs16.x"
  source_code_hash = data.archive_file.admin_api.output_base64sha256

  environment {
    variables = {
      LOG_LEVEL = var.log_level
      PROJECT_STORE = var.project_store_name
      FRONTEND_STORE = var.frontend_store_name
      CONSUMER_STORE = var.consumer_store_name
      VERSION_STORE = var.version_store_name
      DEPLOYMENT_STORE = var.deployment_store_name
      AWS_ENDPOINT_URL = "http://172.17.0.1:4566"
    }
  }
}

# Consumer API Lambda
resource "aws_lambda_function" "consumer_api" {
  provider         = aws.lambda
  filename         = data.archive_file.consumer_api.output_path
  source_code_hash = data.archive_file.consumer_api.output_base64sha256
  function_name    = "consumer-api"
  role            = aws_iam_role.lambda_role.arn
  handler         = "app.handler"
  runtime         = "nodejs16.x"

  environment {
    variables = {
      LOG_LEVEL = var.log_level
      CONSUMER_STORE = var.consumer_store_name
      ACCESS_CONTROL_ALLOW_ORIGIN = var.access_control_allow_origin
    }
  }
}

# Stream Lambda
resource "aws_lambda_function" "stream_processor" {
  provider         = aws.lambda
  filename         = data.archive_file.stream_processor.output_path
  source_code_hash = data.archive_file.stream_processor.output_base64sha256
  function_name    = "stream-processor"
  role            = aws_iam_role.lambda_role.arn
  handler         = "app.handler"
  runtime         = "nodejs16.x"

  environment {
    variables = {
      LOG_LEVEL = var.log_level
      FRONTEND_STORE = var.frontend_store_name
      PROJECT_STORE = var.project_store_name
      CONSUMER_STORE = var.consumer_store_name
      VERSION_STORE = var.version_store_name
    }
  }
}

# Lambda permissions
resource "aws_lambda_permission" "api_gateway" {
  provider      = aws.lambda
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.admin_api.function_name
  principal     = "apigateway.amazonaws.com"
}

# DynamoDB trigger for stream processor
resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  provider         = aws.lambda
  event_source_arn  = var.dynamodb_stream_arn
  function_name     = aws_lambda_function.stream_processor.arn
  starting_position = "LATEST"
}

# IAM policies
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name = "dynamodb-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          var.frontend_store_arn,
          var.project_store_arn,
          var.consumer_store_arn,
          var.version_store_arn,
          var.deployment_store_arn
        ]
      }
    ]
  })
}