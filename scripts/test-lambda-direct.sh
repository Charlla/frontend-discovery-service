#!/bin/bash
set -e

echo "Testing Lambda function directly..."

# Set AWS credentials
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Create temporary payload file
PAYLOAD_FILE=$(mktemp)
echo '{
  "httpMethod": "POST",
  "path": "/admin/api/projects",
  "body": "{\"name\":\"test-project\"}",
  "headers": {
    "Authorization": "Bearer test-token",
    "Content-Type": "application/json"
  }
}' > $PAYLOAD_FILE

# Show payload for debugging
echo "Payload:"
cat $PAYLOAD_FILE | jq '.'

# Invoke Lambda
echo -e "\nInvoking Lambda function..."
aws --endpoint-url=http://localhost:4566 \
    lambda invoke \
    --function-name admin-api \
    --payload "fileb://$PAYLOAD_FILE" \
    --cli-binary-format raw-in-base64-out \
    /tmp/lambda-output.txt

echo -e "\nLambda response:"
cat /tmp/lambda-output.txt

# Check DynamoDB
echo -e "\nChecking DynamoDB..."
aws --endpoint-url=http://localhost:4566 \
    dynamodb scan \
    --table-name ProjectStore

# Show Lambda logs
echo -e "\nLambda logs:"
aws --endpoint-url=http://localhost:4566 \
    logs get-log-events \
    --log-group-name /aws/lambda/admin-api \
    --log-stream-name $(aws --endpoint-url=http://localhost:4566 \
        logs describe-log-streams \
        --log-group-name /aws/lambda/admin-api \
        --order-by LastEventTime \
        --descending \
        --limit 1 \
        --query 'logStreams[0].logStreamName' \
        --output text) \
    --query 'events[*].message' \
    --output text || echo "No logs found"

# Cleanup
rm -f $PAYLOAD_FILE