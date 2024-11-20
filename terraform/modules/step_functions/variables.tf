variable "deployment_store_arn" {
  description = "ARN of the Deployment DynamoDB table"
  type        = string
}

variable "frontend_store_arn" {
  description = "ARN of the Frontend DynamoDB table"
  type        = string
}

variable "deployment_store_name" {
  description = "Name of the Deployment DynamoDB table"
  type        = string
} 