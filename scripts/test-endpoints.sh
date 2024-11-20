#!/bin/bash
set -e

# Set AWS credentials and region
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

BASE_URL=${API_URL:-http://localhost:4566}
AUTH_TOKEN="test-token"

echo "Testing API endpoints..."
echo "Using base URL: $BASE_URL"

# Function to make API request with proper error handling
make_request() {
    local method=$1
    local endpoint=$2
    local payload=$3
    local temp_file=$(mktemp)
    local response_file=$(mktemp)
    
    echo "----------------------------------------"
    echo "Testing $method $endpoint"
    echo "----------------------------------------"
    
    if [ -n "$payload" ]; then
        echo "Payload:"
        echo "$payload" | jq '.'
        echo "$payload" > "$temp_file"
    fi
    
    # Make the request
    if [ -n "$payload" ]; then
        curl -s -X $method \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $AUTH_TOKEN" \
            -d "@$temp_file" \
            "$BASE_URL$endpoint" > "$response_file"
    else
        curl -s -X $method \
            -H "Authorization: Bearer $AUTH_TOKEN" \
            "$BASE_URL$endpoint" > "$response_file"
    fi
    
    # Check if response is valid JSON
    if jq -e . >/dev/null 2>&1 <<<"$(cat $response_file)"; then
        echo "Response (JSON):"
        cat "$response_file" | jq '.'
        cat "$response_file"
    else
        echo "Response (raw):"
        cat "$response_file"
        echo ""
    fi
    
    # Cleanup
    rm -f "$temp_file" "$response_file"
}

echo "Testing Admin API endpoints..."

# Test POST /admin/api/projects
echo "Creating test project..."
PROJECT_RESPONSE=$(make_request "POST" "/admin/api/projects" '{
    "name": "test-project"
}')

# Extract project ID if response is JSON
if echo "$PROJECT_RESPONSE" | jq -e . >/dev/null 2>&1; then
    PROJECT_ID=$(echo "$PROJECT_RESPONSE" | jq -r '.id // empty')
    if [ -n "$PROJECT_ID" ]; then
        echo "Created project with ID: $PROJECT_ID"
        
        # Test GET specific project
        make_request "GET" "/admin/api/projects/$PROJECT_ID"
        
        # Test POST micro-frontend
        MFE_RESPONSE=$(make_request "POST" "/admin/api/projects/$PROJECT_ID/microFrontends" '{
            "name": "test-frontend",
            "metadata": {
                "type": "module"
            }
        }')
        
        # Extract MFE ID if response is JSON
        if echo "$MFE_RESPONSE" | jq -e . >/dev/null 2>&1; then
            MFE_ID=$(echo "$MFE_RESPONSE" | jq -r '.id // empty')
            if [ -n "$MFE_ID" ]; then
                echo "Created MFE with ID: $MFE_ID"
                make_request "GET" "/admin/api/projects/$PROJECT_ID/microFrontends"
                make_request "GET" "/consumer/api/projects/$PROJECT_ID/microFrontends"
            fi
        fi
    fi
fi

# Check DynamoDB tables
echo -e "\nChecking DynamoDB tables..."
aws --endpoint-url=http://localhost:4566 \
    dynamodb scan \
    --table-name ProjectStore

echo "All endpoint tests completed!" 