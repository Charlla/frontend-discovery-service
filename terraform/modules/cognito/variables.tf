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