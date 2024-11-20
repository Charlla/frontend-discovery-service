#!/bin/bash

echo "Verifying Lambda functions..."

# Set AWS local configuration
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test

# Function to check Lambda function
check_lambda() {
    local func_name=$1
    echo "Checking $func_name..."
    
    # Check if function exists
    if aws --endpoint-url=http://localhost:4566 lambda get-function --function-name $func_name 2>/dev/null; then
        echo "✅ $func_name exists"
        
        # Test invoke
        echo "Testing $func_name..."
        aws --endpoint-url=http://localhost:4566 lambda invoke \
            --function-name $func_name \
            --payload '{"test": "event"}' \
            /tmp/lambda-output.txt
        
        echo "Response:"
        cat /tmp/lambda-output.txt
    else
        echo "❌ $func_name not found"
        
        # Show Lambda functions list
        echo "Available functions:"
        aws --endpoint-url=http://localhost:4566 lambda list-functions
    fi
}

# Check each Lambda function
check_lambda "admin-api"
check_lambda "consumer-api"
check_lambda "stream-processor"

echo "Verification complete!" 