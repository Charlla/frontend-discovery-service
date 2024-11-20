variable "admin_lambda_invoke_arn" {
  description = "ARN for invoking the admin Lambda function"
  type        = string
}

variable "consumer_lambda_invoke_arn" {
  description = "ARN for invoking the consumer Lambda function"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  type        = string
}

variable "stage_name" {
  description = "Stage name for API Gateway deployment"
  type        = string
  default     = "prod"
} 