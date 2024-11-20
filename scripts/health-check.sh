#!/bin/bash
set -e

echo "Checking LocalStack health..."
curl -s http://localhost:4566/_localstack/health

echo "Checking API endpoints..."
curl -s http://localhost:4566/admin/health
curl -s http://localhost:4566/consumer/health 