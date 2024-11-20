#!/bin/bash
set -e

echo "Installing Lambda dependencies..."

# Function to install dependencies for a Lambda function
install_deps() {
    local dir=$1
    echo "Installing dependencies for $dir..."
    cd "infrastructure/lambda/$dir"
    npm install
    cd ../../../
}

# Install dependencies for each Lambda function
install_deps "adminApi"
install_deps "consumerApi"
install_deps "stream"

echo "Lambda dependencies installed!" 