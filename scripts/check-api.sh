#!/bin/bash
set -e

echo "Checking API Gateway configuration..."

# Set AWS credentials
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# List APIs
echo "APIs:"
aws --endpoint-url=http://localhost:4566 \
    apigateway get-rest-apis

# Get API ID
API_ID=$(aws --endpoint-url=http://localhost:4566 \
    apigateway get-rest-apis \
    --query 'items[?name==`frontend-discovery-admin`].id' \
    --output text)

if [ -n "$API_ID" ]; then
    echo -e "\nResources for API $API_ID:"
    aws --endpoint-url=http://localhost:4566 \
        apigateway get-resources \
        --rest-api-id $API_ID

    echo -e "\nStages for API $API_ID:"
    aws --endpoint-url=http://localhost:4566 \
        apigateway get-stages \
        --rest-api-id $API_ID

    echo -e "\nDeployments for API $API_ID:"
    aws --endpoint-url=http://localhost:4566 \
        apigateway get-deployments \
        --rest-api-id $API_ID
else
    echo "Admin API not found!"
fi 