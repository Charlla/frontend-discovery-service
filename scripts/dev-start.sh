#!/bin/bash
set -e

# Check if virtual environment exists, if not run setup
if [ ! -d ".venv" ]; then
    echo "Virtual environment not found. Running setup script first..."
    ./scripts/setup-local-dev.sh
fi

# Load environment variables
export $(cat .env | xargs)

# Set AWS local configuration
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localhost:4566

# Install Lambda dependencies
echo "Installing Lambda dependencies..."
./scripts/install-lambda-deps.sh

# Start LocalStack
echo "Starting LocalStack..."
docker-compose down -v # Ensure clean state
docker-compose up -d

# Wait for LocalStack to be ready
echo "Waiting for LocalStack to be ready..."
TIMEOUT=30
COUNTER=0

while true; do
    if [ $COUNTER -eq $TIMEOUT ]; then
        echo "Timeout waiting for LocalStack to be ready"
        echo "LocalStack health status:"
        curl -s http://localhost:4566/_localstack/health
        echo "LocalStack logs:"
        docker-compose logs localstack
        docker-compose down
        exit 1
    fi

    HEALTH_STATUS=$(curl -s http://localhost:4566/_localstack/health || echo "Failed to connect")
    
    if [[ $HEALTH_STATUS == "Failed to connect" ]]; then
        echo "Waiting for LocalStack to start... ($COUNTER seconds)"
        sleep 1
        COUNTER=$((COUNTER + 1))
        continue
    fi

    echo "Checking services... ($COUNTER seconds)"
    echo "Current health status:"
    echo $HEALTH_STATUS | jq '.'

    # Check each service individually and report status
    for service in dynamodb lambda apigateway stepfunctions; do
        SERVICE_STATUS=$(echo $HEALTH_STATUS | jq -r ".services.\"$service\"")
        echo "Service $service status: $SERVICE_STATUS"
        if [[ $SERVICE_STATUS != "available" ]]; then
            echo "Waiting for $service to become available..."
        fi
    done

    # Check if all required services are available
    if echo $HEALTH_STATUS | jq -e '.services | select(.dynamodb == "available" and .lambda == "available" and .apigateway == "available" and .stepfunctions == "available")' > /dev/null; then
        echo "All required services are available!"
        break
    fi

    sleep 1
    COUNTER=$((COUNTER + 1))
done

echo "LocalStack is ready!"

# Apply Terraform configuration
echo "Applying Terraform configuration..."
./scripts/apply-terraform.sh

echo "Local environment is ready!" 