#!/bin/bash

echo "Testing Lambda setup..."

# Set AWS credentials
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Create test function
echo "Creating test function..."
cd infrastructure/lambda/adminApi
zip -r function.zip .
aws --endpoint-url=http://localhost:4566 \
    lambda create-function \
    --function-name test-function \
    --runtime nodejs16.x \
    --handler app.handler \
    --role arn:aws:iam::000000000000:role/lambda-role \
    --zip-file fileb://function.zip

# Test invoke
echo "Invoking test function..."
aws --endpoint-url=http://localhost:4566 \
    lambda invoke \
    --function-name test-function \
    --payload '{"test": true}' \
    output.txt

cat output.txt 