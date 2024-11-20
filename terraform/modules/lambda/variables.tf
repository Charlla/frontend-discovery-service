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

variable "frontend_store_arn" {
  description = "ARN of the Frontend DynamoDB table"
  type        = string
}

variable "project_store_arn" {
  description = "ARN of the Project DynamoDB table"
  type        = string
}

variable "consumer_store_arn" {
  description = "ARN of the Consumer DynamoDB table"
  type        = string
}

variable "version_store_arn" {
  description = "ARN of the Version DynamoDB table"
  type        = string
}

variable "deployment_store_arn" {
  description = "ARN of the Deployment DynamoDB table"
  type        = string
}

variable "frontend_store_name" {
  description = "Name of the Frontend DynamoDB table"
  type        = string
}

variable "project_store_name" {
  description = "Name of the Project DynamoDB table"
  type        = string
}

variable "consumer_store_name" {
  description = "Name of the Consumer DynamoDB table"
  type        = string
}

variable "version_store_name" {
  description = "Name of the Version DynamoDB table"
  type        = string
}

variable "deployment_store_name" {
  description = "Name of the Deployment DynamoDB table"
  type        = string
}

variable "dynamodb_stream_arn" {
  description = "ARN of the DynamoDB stream to process"
  type        = string
} 