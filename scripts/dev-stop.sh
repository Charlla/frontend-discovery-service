#!/bin/bash
set -e

# Activate virtual environment
source .venv/bin/activate

# Destroy Terraform resources
echo "Destroying Terraform resources..."
tflocal destroy -auto-approve

# Stop LocalStack
echo "Stopping LocalStack..."
docker-compose down

# Clean up with proper permissions
echo "Cleaning up local state..."
sudo rm -rf .localstack
rm -rf .terraform*

echo "Local environment stopped!" 