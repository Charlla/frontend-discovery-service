variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "enable_dynamodb_backups" {
  description = "Enable DynamoDB point-in-time recovery backups"
  type        = bool
  default     = false
}

variable "log_level" {
  description = "Log level for Lambda functions"
  type        = string
  default     = "INFO"
}

variable "access_control_allow_origin" {
  description = "CORS Allow-Origin header value"
  type        = string
  default     = "*"
}

variable "stage" {
  description = "Stage name for API Gateway deployment"
  type        = string
  default     = "prod"
}

variable "default_user_email" {
  description = "Email for default admin user"
  type        = string
  default     = ""
}

variable "cognito_advanced_security" {
  description = "Advanced security mode for Cognito"
  type        = string
  default     = "OFF"
} 