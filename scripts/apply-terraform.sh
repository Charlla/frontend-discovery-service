#!/bin/bash
set -e

echo "Applying Terraform configuration..."

# Set AWS local configuration
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Activate virtual environment
source .venv/bin/activate

# Initialize and apply Terraform
cd terraform
tflocal init
tflocal apply -auto-approve

# Verify resources
echo "Verifying resources..."

echo "Checking DynamoDB tables..."
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

echo "Checking Lambda functions..."
aws --endpoint-url=http://localhost:4566 lambda list-functions

echo "Checking API Gateway..."
aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis

echo "Resources created successfully!" 