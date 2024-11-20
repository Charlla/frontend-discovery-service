# Mock Cognito resources for local development
resource "null_resource" "mock_cognito" {
  # This is a mock resource that does nothing
}

# Export mock values that other resources need
locals {
  mock_user_pool_arn = "arn:aws:cognito-idp:us-east-1:000000000000:userpool/mock-user-pool"
  mock_user_pool_id = "mock-user-pool"
  mock_client_id = "mock-client-id"
} 