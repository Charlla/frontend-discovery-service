terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

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
    enabled        = true
  }

  point_in_time_recovery {
    enabled = var.enable_backups
  }
}

# Frontend Store
resource "aws_dynamodb_table" "frontend_store" {
  name           = "FrontendStore"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "mfeId"
  range_key      = "projectId"
  stream_enabled = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "mfeId"
    type = "S"
  }

  attribute {
    name = "projectId"
    type = "S"
  }

  global_secondary_index {
    name               = "ProjectIndex"
    hash_key           = "projectId"
    projection_type    = "ALL"
    write_capacity     = 0
    read_capacity      = 0
  }
}

# Version Store
resource "aws_dynamodb_table" "version_store" {
  name           = "VersionStore"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "versionId"
  range_key      = "mfeId"
  stream_enabled = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "versionId"
    type = "S"
  }

  attribute {
    name = "mfeId"
    type = "S"
  }

  global_secondary_index {
    name               = "MfeIndex"
    hash_key           = "mfeId"
    projection_type    = "ALL"
    write_capacity     = 0
    read_capacity      = 0
  }
}

# Deployment Store
resource "aws_dynamodb_table" "deployment_store" {
  name           = "DeploymentStore"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "deploymentId"
  stream_enabled = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "deploymentId"
    type = "S"
  }
}

# Consumer Store
resource "aws_dynamodb_table" "consumer_store" {
  name           = "ConsumerStore"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "consumerId"
  stream_enabled = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "consumerId"
    type = "S"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }
}

# Define other tables similarly 