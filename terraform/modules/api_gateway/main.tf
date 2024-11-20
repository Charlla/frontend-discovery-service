resource "aws_api_gateway_rest_api" "admin_api" {
  name = "frontend-discovery-admin"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_rest_api" "consumer_api" {
  name = "frontend-discovery-consumer"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Admin API Resources
resource "aws_api_gateway_resource" "admin_api" {
  rest_api_id = aws_api_gateway_rest_api.admin_api.id
  parent_id   = aws_api_gateway_rest_api.admin_api.root_resource_id
  path_part   = "admin"
}

resource "aws_api_gateway_resource" "admin_api_projects" {
  rest_api_id = aws_api_gateway_rest_api.admin_api.id
  parent_id   = aws_api_gateway_resource.admin_api.id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "admin_projects" {
  rest_api_id = aws_api_gateway_rest_api.admin_api.id
  parent_id   = aws_api_gateway_resource.admin_api_projects.id
  path_part   = "projects"
}

# Admin API Methods
resource "aws_api_gateway_method" "admin_projects_post" {
  rest_api_id   = aws_api_gateway_rest_api.admin_api.id
  resource_id   = aws_api_gateway_resource.admin_projects.id
  http_method   = "POST"
  authorization = "NONE"  # Always use NONE for local development
}

resource "aws_api_gateway_method" "admin_projects_get" {
  rest_api_id   = aws_api_gateway_rest_api.admin_api.id
  resource_id   = aws_api_gateway_resource.admin_projects.id
  http_method   = "GET"
  authorization = "NONE"  # Always use NONE for local development
}

# Admin API Integrations
resource "aws_api_gateway_integration" "admin_projects_post" {
  rest_api_id             = aws_api_gateway_rest_api.admin_api.id
  resource_id             = aws_api_gateway_resource.admin_projects.id
  http_method             = aws_api_gateway_method.admin_projects_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.admin_lambda_invoke_arn
}

resource "aws_api_gateway_integration" "admin_projects_get" {
  rest_api_id             = aws_api_gateway_rest_api.admin_api.id
  resource_id             = aws_api_gateway_resource.admin_projects.id
  http_method             = aws_api_gateway_method.admin_projects_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.admin_lambda_invoke_arn
}

# Add method response
resource "aws_api_gateway_method_response" "admin_projects_post_200" {
  rest_api_id = aws_api_gateway_rest_api.admin_api.id
  resource_id = aws_api_gateway_resource.admin_projects.id
  http_method = aws_api_gateway_method.admin_projects_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# Add integration response
resource "aws_api_gateway_integration_response" "admin_projects_post_200" {
  rest_api_id = aws_api_gateway_rest_api.admin_api.id
  resource_id = aws_api_gateway_resource.admin_projects.id
  http_method = aws_api_gateway_method.admin_projects_post.http_method
  status_code = aws_api_gateway_method_response.admin_projects_post_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.admin_projects_post,
    aws_api_gateway_method_response.admin_projects_post_200
  ]
}

# Admin API Root Method (for GET /admin/api/projects)
resource "aws_api_gateway_method" "admin_root_get" {
  rest_api_id   = aws_api_gateway_rest_api.admin_api.id
  resource_id   = aws_api_gateway_resource.admin_projects.id
  http_method   = "GET"
  authorization = "NONE"  # For local testing
}

resource "aws_api_gateway_integration" "admin_root_get" {
  rest_api_id = aws_api_gateway_rest_api.admin_api.id
  resource_id = aws_api_gateway_resource.admin_projects.id
  http_method = aws_api_gateway_method.admin_root_get.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = var.admin_lambda_invoke_arn
}

# Consumer API Resources
resource "aws_api_gateway_resource" "consumer_api" {
  rest_api_id = aws_api_gateway_rest_api.consumer_api.id
  parent_id   = aws_api_gateway_rest_api.consumer_api.root_resource_id
  path_part   = "consumer"
}

resource "aws_api_gateway_resource" "consumer_api_projects" {
  rest_api_id = aws_api_gateway_rest_api.consumer_api.id
  parent_id   = aws_api_gateway_resource.consumer_api.id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "consumer_projects" {
  rest_api_id = aws_api_gateway_rest_api.consumer_api.id
  parent_id   = aws_api_gateway_resource.consumer_api_projects.id
  path_part   = "projects"
}

# Consumer API Methods
resource "aws_api_gateway_method" "consumer_projects_get" {
  rest_api_id   = aws_api_gateway_rest_api.consumer_api.id
  resource_id   = aws_api_gateway_resource.consumer_projects.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "consumer_projects_get" {
  rest_api_id = aws_api_gateway_rest_api.consumer_api.id
  resource_id = aws_api_gateway_resource.consumer_projects.id
  http_method = aws_api_gateway_method.consumer_projects_get.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = var.consumer_lambda_invoke_arn
}

# CORS Configuration
resource "aws_api_gateway_method" "admin_projects_options" {
  rest_api_id   = aws_api_gateway_rest_api.admin_api.id
  resource_id   = aws_api_gateway_resource.admin_projects.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# CORS Integration
resource "aws_api_gateway_integration" "admin_projects_options" {
  rest_api_id = aws_api_gateway_rest_api.admin_api.id
  resource_id = aws_api_gateway_resource.admin_projects.id
  http_method = aws_api_gateway_method.admin_projects_options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  depends_on = [
    aws_api_gateway_method.admin_projects_options
  ]
}

# CORS Method Response
resource "aws_api_gateway_method_response" "admin_projects_options_200" {
  rest_api_id = aws_api_gateway_rest_api.admin_api.id
  resource_id = aws_api_gateway_resource.admin_projects.id
  http_method = aws_api_gateway_method.admin_projects_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = [
    aws_api_gateway_method.admin_projects_options,
    aws_api_gateway_integration.admin_projects_options
  ]
}

# CORS Integration Response
resource "aws_api_gateway_integration_response" "admin_projects_options_200" {
  rest_api_id = aws_api_gateway_rest_api.admin_api.id
  resource_id = aws_api_gateway_resource.admin_projects.id
  http_method = aws_api_gateway_method.admin_projects_options.http_method
  status_code = aws_api_gateway_method_response.admin_projects_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method.admin_projects_options,
    aws_api_gateway_integration.admin_projects_options,
    aws_api_gateway_method_response.admin_projects_options_200
  ]
}

# Deployments
resource "aws_api_gateway_deployment" "admin" {
  rest_api_id = aws_api_gateway_rest_api.admin_api.id

  depends_on = [
    aws_api_gateway_integration.admin_projects_post,
    aws_api_gateway_integration.admin_projects_get,
    aws_api_gateway_integration.admin_root_get,
    aws_api_gateway_integration.admin_projects_options,
    aws_api_gateway_integration_response.admin_projects_options_200,
    aws_api_gateway_method_response.admin_projects_options_200
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.admin_projects.id,
      aws_api_gateway_method.admin_projects_post.id,
      aws_api_gateway_method.admin_projects_get.id,
      aws_api_gateway_method.admin_root_get.id,
      aws_api_gateway_integration.admin_projects_post.id,
      aws_api_gateway_integration.admin_projects_get.id,
      aws_api_gateway_integration.admin_root_get.id,
      aws_api_gateway_method.admin_projects_options.id,
      aws_api_gateway_integration.admin_projects_options.id,
      aws_api_gateway_method_response.admin_projects_options_200.id,
      aws_api_gateway_integration_response.admin_projects_options_200.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_deployment" "consumer" {
  rest_api_id = aws_api_gateway_rest_api.consumer_api.id
  depends_on = [
    aws_api_gateway_integration.consumer_projects_get
  ]
}

resource "aws_api_gateway_stage" "admin" {
  deployment_id = aws_api_gateway_deployment.admin.id
  rest_api_id  = aws_api_gateway_rest_api.admin_api.id
  stage_name   = var.stage_name

  variables = {
    "lambdaAlias" = var.stage_name
  }
}

resource "aws_api_gateway_stage" "consumer" {
  deployment_id = aws_api_gateway_deployment.consumer.id
  rest_api_id  = aws_api_gateway_rest_api.consumer_api.id
  stage_name   = var.stage_name

  variables = {
    "lambdaAlias" = var.stage_name
  }
}

# Add base path mapping
resource "aws_api_gateway_base_path_mapping" "admin" {
  api_id      = aws_api_gateway_rest_api.admin_api.id
  stage_name  = aws_api_gateway_stage.admin.stage_name
  domain_name = "localhost"
}

# Add similar settings for consumer API
# ... rest of the code ...