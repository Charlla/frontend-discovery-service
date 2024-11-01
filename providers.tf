provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "us-east-1"

  # LocalStack settings
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    iam           = "http://localhost:4566"
    lambda        = "http://localhost:4566"
    s3            = "http://localhost:4566"
    sns           = "http://localhost:4566"
    sqs           = "http://localhost:4566"
    sts           = "http://localhost:4566"
    cognitoidentity = "http://localhost:4566"
    cognitoidp    = "http://localhost:4566"
    stepfunctions = "http://localhost:4566"
  }
} 