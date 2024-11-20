#!/bin/bash

echo "Debugging Lambda functions..."

# Set AWS local configuration
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test

# List Lambda functions
echo "Listing Lambda functions:"
aws --endpoint-url=http://localhost:4566 \
    --region us-east-1 \
    lambda list-functions

# Test Admin API Lambda
echo -e "\nTesting Admin API Lambda:"
aws --endpoint-url=http://localhost:4566 \
    --region us-east-1 \
    lambda invoke \
    --function-name admin-api \
    --payload '{"httpMethod":"POST","path":"/admin/api/projects","body":"{\"name\":\"test-project\"}"}' \
    /tmp/lambda-output.txt

echo "Response:"
if [ -f /tmp/lambda-output.txt ]; then
    cat /tmp/lambda-output.txt
else
    echo "No response file found"
fi

# Test Consumer API Lambda
echo -e "\nTesting Consumer API Lambda:"
aws --endpoint-url=http://localhost:4566 \
    --region us-east-1 \
    lambda invoke \
    --function-name consumer-api \
    --payload '{"httpMethod":"GET","path":"/consumer/api/projects"}' \
    /tmp/lambda-output.txt

echo "Response:"
if [ -f /tmp/lambda-output.txt ]; then
    cat /tmp/lambda-output.txt
else
    echo "No response file found"
fi

# Show Lambda logs
echo -e "\nLambda Logs:"
aws --endpoint-url=http://localhost:4566 \
    --region us-east-1 \
    logs describe-log-groups \
    --log-group-name-prefix /aws/lambda/

# Check if Lambda functions exist
echo -e "\nChecking Lambda function configurations:"
for func in admin-api consumer-api stream-processor; do
    echo "Function: $func"
    aws --endpoint-url=http://localhost:4566 \
        --region us-east-1 \
        lambda get-function \
        --function-name $func || echo "Function $func not found"
done 