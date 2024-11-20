terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Default provider configuration
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    lambda      = "http://localhost:4566"
    dynamodb    = "http://localhost:4566"
    apigateway  = "http://localhost:4566"
    iam         = "http://localhost:4566"
    sts         = "http://localhost:4566"
    cognito-idp = "http://localhost:4566"
    s3          = "http://localhost:4566"
  }

  default_tags {
    tags = {
      Environment = "local"
      Project     = "frontend-discovery"
    }
  }
}

module "dynamodb_tables" {
  source = "./modules/dynamodb"
  enable_backups = var.enable_dynamodb_backups
}

module "lambda_functions" {
  source = "./modules/lambda"
  log_level = var.log_level
  access_control_allow_origin = var.access_control_allow_origin
  frontend_store_arn = module.dynamodb_tables.frontend_store_arn
  project_store_arn = module.dynamodb_tables.project_store_arn
  consumer_store_arn = module.dynamodb_tables.consumer_store_arn
  version_store_arn = module.dynamodb_tables.version_store_arn
  deployment_store_arn = module.dynamodb_tables.deployment_store_arn
  frontend_store_name = module.dynamodb_tables.frontend_store_name
  project_store_name = module.dynamodb_tables.project_store_name
  consumer_store_name = module.dynamodb_tables.consumer_store_name
  version_store_name = module.dynamodb_tables.version_store_name
  deployment_store_name = module.dynamodb_tables.deployment_store_name
  dynamodb_stream_arn = module.dynamodb_tables.dynamodb_stream_arn
}

module "api_gateway" {
  source = "./modules/api_gateway"
  stage_name = var.stage
  admin_lambda_invoke_arn = module.lambda_functions.admin_lambda_invoke_arn
  consumer_lambda_invoke_arn = module.lambda_functions.consumer_lambda_invoke_arn
  cognito_user_pool_arn = module.cognito.user_pool_arn
}

module "cognito" {
  source = "./modules/cognito"
}

module "step_functions" {
  source = "./modules/step_functions"
  deployment_store_arn = module.dynamodb_tables.deployment_store_arn
  frontend_store_arn = module.dynamodb_tables.frontend_store_arn
  deployment_store_name = module.dynamodb_tables.deployment_store_name
}

# Add other modules as needed 