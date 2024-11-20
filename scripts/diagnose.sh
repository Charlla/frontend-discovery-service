#!/bin/bash

echo "Running full system diagnostic..."

# Set AWS local configuration
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Check LocalStack
echo "1. Checking LocalStack..."
docker ps | grep localstack
docker logs frontend-discovery-localstack

# Check Lambda source files
echo "2. Checking Lambda source files..."
ls -la infrastructure/lambda/*/
ls -la infrastructure/lambda/*/node_modules

# Check LocalStack services
echo "3. Checking LocalStack services..."
curl -s http://localhost:4566/_localstack/health | jq '.'

# Check Lambda functions
echo "4. Checking Lambda functions..."
aws --endpoint-url=http://localhost:4566 \
    --region us-east-1 \
    lambda list-functions

# Check API Gateway
echo "5. Checking API Gateway..."
aws --endpoint-url=http://localhost:4566 \
    --region us-east-1 \
    apigateway get-rest-apis

# Check DynamoDB
echo "6. Checking DynamoDB..."
aws --endpoint-url=http://localhost:4566 \
    --region us-east-1 \
    dynamodb list-tables

# Print environment
echo "7. Environment variables:"
env | grep -E 'AWS_|LOCALSTACK_|DEBUG'

# Check if LocalStack is healthy
echo "8. LocalStack Health Check:"
curl -s http://localhost:4566/_localstack/health | jq '.services | to_entries | map(select(.value == "available")) | map(.key)'

echo "Diagnostic complete!" 