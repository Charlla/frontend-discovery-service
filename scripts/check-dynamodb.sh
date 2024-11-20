#!/bin/bash

echo "Checking DynamoDB tables..."

# Set AWS local configuration
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# List tables
echo "Tables:"
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

# Scan ProjectStore
echo -e "\nProjectStore contents:"
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name ProjectStore

# Show table description
echo -e "\nProjectStore description:"
aws --endpoint-url=http://localhost:4566 dynamodb describe-table --table-name ProjectStore 