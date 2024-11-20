#!/bin/bash

echo "Debugging API Gateway configuration..."

# Check LocalStack status
echo "LocalStack health:"
curl -s http://localhost:4566/_localstack/health | jq '.'

# List APIs
echo -e "\nListing APIs:"
aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis

# Get Admin API details
ADMIN_API_ID=$(aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis | jq -r '.items[] | select(.name=="frontend-discovery-admin") | .id')

if [ -n "$ADMIN_API_ID" ]; then
    echo -e "\nAdmin API resources:"
    aws --endpoint-url=http://localhost:4566 apigateway get-resources --rest-api-id $ADMIN_API_ID
fi

# Get Consumer API details
CONSUMER_API_ID=$(aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis | jq -r '.items[] | select(.name=="frontend-discovery-consumer") | .id')

if [ -n "$CONSUMER_API_ID" ]; then
    echo -e "\nConsumer API resources:"
    aws --endpoint-url=http://localhost:4566 apigateway get-resources --rest-api-id $CONSUMER_API_ID
fi 