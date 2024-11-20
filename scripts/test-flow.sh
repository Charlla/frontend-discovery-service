#!/bin/bash
set -e

echo "Testing full flow..."

# Set AWS credentials
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Create a project
echo "Creating project..."
PROJECT_RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer test-token" \
    -d '{"name": "test-project"}' \
    http://localhost:4566/admin/api/projects)

echo "Project creation response:"
echo "$PROJECT_RESPONSE"

# Extract project ID
if [ -n "$PROJECT_RESPONSE" ]; then
    PROJECT_ID=$(echo "$PROJECT_RESPONSE" | jq -r '.id // empty')
    if [ -n "$PROJECT_ID" ] && [ "$PROJECT_ID" != "null" ]; then
        echo "Project created with ID: $PROJECT_ID"

        # Check DynamoDB
        echo "Checking DynamoDB..."
        aws --endpoint-url=http://localhost:4566 \
            dynamodb scan \
            --table-name ProjectStore

        # Get project details
        echo "Getting project details..."
        curl -s -X GET \
            -H "Authorization: Bearer test-token" \
            "http://localhost:4566/admin/api/projects/$PROJECT_ID" | jq '.'
    else
        echo "Failed to extract project ID from response"
        exit 1
    fi
else
    echo "No response received from API"
    exit 1
fi 