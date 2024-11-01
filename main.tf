terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# provider "aws" {
#   access_key = "test"
#   secret_key = "test"
#   region = "us-east-1"

#   # LocalStack settings
#   skip_credentials_validation = true
#   skip_metadata_api_check = true
#   skip_requesting_account_id = true

#   endpoints {
#     apigateway     = "http://localhost:4566"
#     cloudformation = "http://localhost:4566"
#     cloudwatch     = "http://localhost:4566"
#     dynamodb       = "http://localhost:4566"
#     es             = "http://localhost:4566"
#     firehose       = "http://localhost:4566"
#     iam            = "http://localhost:4566"
#     kinesis       = "http://localhost:4566"
#     lambda         = "http://localhost:4566"
#     route53       = "http://localhost:4566"
#     redshift      = "http://localhost:4566"
#     s3            = "http://localhost:4566"
#     secretsmanager = "http://localhost:4566"
#     ses           = "http://localhost:4566"
#     sns           = "http://localhost:4566"
#     sqs           = "http://localhost:4566"
#     ssm           = "http://localhost:4566"
#     stepfunctions = "http://localhost:4566"
#     sts           = "http://localhost:4566"
#   }
# }

# DynamoDB Tables
resource "aws_dynamodb_table" "project_store" {
  name           = "ProjectStore"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "projectId"
  stream_enabled = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "projectId"
    type = "S"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled = true
  }
}

resource "aws_dynamodb_table" "frontend_store" {
  name           = "FrontendStore"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "projectId"
  range_key      = "microFrontendId"
  stream_enabled = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "projectId"
    type = "S"
  }

  attribute {
    name = "microFrontendId"
    type = "S"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled = true
  }
}

# Consumer View Store
resource "aws_dynamodb_table" "consumer_view_store" {
  name           = "ConsumerViewStore"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "projectId"
  range_key      = "microFrontendId"

  attribute {
    name = "projectId"
    type = "S"
  }

  attribute {
    name = "microFrontendId"
    type = "S"
  }
}

# Deployment Store
resource "aws_dynamodb_table" "deployment_store" {
  name           = "DeploymentStore"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "deploymentId"
  range_key      = "sk"

  attribute {
    name = "deploymentId"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled = true
  }
}

# Version Store
resource "aws_dynamodb_table" "version_store" {
  name           = "VersionStore"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "microFrontendId"
  range_key      = "version"

  attribute {
    name = "microFrontendId"
    type = "S"
  }

  attribute {
    name = "version"
    type = "S"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled = true
  }
}

# IAM Roles
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-policy"
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
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.project_store.arn,
          aws_dynamodb_table.frontend_store.arn,
          aws_dynamodb_table.consumer_view_store.arn,
          aws_dynamodb_table.deployment_store.arn,
          aws_dynamodb_table.version_store.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

# Lambda Functions
resource "aws_lambda_function" "stream_handler" {
  filename         = "dist/stream/app.zip"
  function_name    = "stream-handler"
  role            = aws_iam_role.lambda_role.arn
  handler         = "app.handler"
  runtime         = "nodejs16.x"
  timeout         = 60

  environment {
    variables = {
      LOG_LEVEL = "INFO"
      REGION = "us-east-1"
      POWERTOOLS_SERVICE_NAME = "streamHandler"
      CONSUMER_STORE = aws_dynamodb_table.consumer_view_store.name
      PROJECT_STORE = aws_dynamodb_table.project_store.name
      FRONTEND_STORE = aws_dynamodb_table.frontend_store.name
      VERSION_STORE = aws_dynamodb_table.version_store.name
    }
  }
}

resource "aws_lambda_function" "consumer_handler" {
  filename         = "dist/consumerApi/app.zip"
  function_name    = "consumer-handler"
  role            = aws_iam_role.lambda_role.arn
  handler         = "app.handler"
  runtime         = "nodejs16.x"
  timeout         = 10

  environment {
    variables = {
      LOG_LEVEL = "INFO"
      REGION = "us-east-1"
      POWERTOOLS_SERVICE_NAME = "consumerApi"
      CONSUMER_STORE = aws_dynamodb_table.consumer_view_store.name
      COOKIE_SETTINGS = "Secure"
    }
  }
}

resource "aws_lambda_function" "admin_handler" {
  filename         = "dist/adminApi/app.zip"
  function_name    = "admin-handler"
  role            = aws_iam_role.lambda_role.arn
  handler         = "app.handler"
  runtime         = "nodejs16.x"
  timeout         = 10

  environment {
    variables = {
      LOG_LEVEL = "INFO"
      REGION = "us-east-1"
      POWERTOOLS_SERVICE_NAME = "AdminAPI"
      PROJECT_STORE = aws_dynamodb_table.project_store.name
      FRONTEND_STORE = aws_dynamodb_table.frontend_store.name
      DEPLOYMENT_STORE = aws_dynamodb_table.deployment_store.name
      VERSION_STORE = aws_dynamodb_table.version_store.name
      DELETE_EXPIRY_MINUTES = "1440"
    }
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "consumer_api" {
  name = "Frontend-Service-Discovery-Consumer-API"
}

resource "aws_api_gateway_resource" "consumer_projects" {
  rest_api_id = aws_api_gateway_rest_api.consumer_api.id
  parent_id   = aws_api_gateway_rest_api.consumer_api.root_resource_id
  path_part   = "projects"
}

resource "aws_api_gateway_resource" "consumer_project_id" {
  rest_api_id = aws_api_gateway_rest_api.consumer_api.id
  parent_id   = aws_api_gateway_resource.consumer_projects.id
  path_part   = "{projectId}"
}

resource "aws_api_gateway_resource" "consumer_microfrontends" {
  rest_api_id = aws_api_gateway_rest_api.consumer_api.id
  parent_id   = aws_api_gateway_resource.consumer_project_id.id
  path_part   = "microFrontends"
}

resource "aws_api_gateway_method" "consumer_get" {
  rest_api_id   = aws_api_gateway_rest_api.consumer_api.id
  resource_id   = aws_api_gateway_resource.consumer_microfrontends.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "consumer_lambda" {
  rest_api_id = aws_api_gateway_rest_api.consumer_api.id
  resource_id = aws_api_gateway_resource.consumer_microfrontends.id
  http_method = aws_api_gateway_method.consumer_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.consumer_handler.invoke_arn
}

# Admin API Gateway
resource "aws_api_gateway_rest_api" "admin_api" {
  name = "Frontend-Service-Discovery-Admin-API"
}

# Similar resources for admin API paths...

# Step Functions
resource "aws_sfn_state_machine" "deployment" {
  name     = "deployment-state-machine"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = file("infrastructure/stepfunctions/deploymentASL.json")
}

resource "aws_iam_role" "step_functions_role" {
  name = "step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

# Cognito
resource "aws_cognito_user_pool" "pool" {
  name = "frontend-discovery-user-pool"

  admin_create_user_config {
    allow_admin_create_user_only = true
    
    invite_message_template {
      sms_message = "Your Frontend Service Discovery username is {username} and the temporary password is {####}"
      email_message = "Your Frontend Service Discovery username is {username} and the temporary password is {####}"
      email_subject = "Your temporary password for Frontend Service Discovery"
    }
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "frontend-discovery-client"
  
  user_pool_id = aws_cognito_user_pool.pool.id
  
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}