#!/bin/bash
set -e

echo "Cleaning up local environment..."

# Stop containers if running
docker-compose down 2>/dev/null || true

# Clean up LocalStack files with sudo
sudo rm -rf .localstack || true

# Clean up other files
rm -rf .terraform* || true
rm -rf .venv || true

echo "Cleanup complete!" 