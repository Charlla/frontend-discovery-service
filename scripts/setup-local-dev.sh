#!/bin/bash
set -e

# Make scripts executable
chmod +x scripts/*.sh

# Check prerequisites
command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed. Aborting." >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "Python3 is required but not installed. Aborting." >&2; exit 1; }
command -v python3-venv >/dev/null 2>&1 || { echo "python3-venv is required. Installing..." >&2; sudo apt-get install -y python3-venv; }

# Create and activate virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv .venv
fi

# Activate virtual environment
source .venv/bin/activate

# Install tflocal if not present
command -v tflocal >/dev/null 2>&1 || {
    echo "tflocal is required but not installed. Installing in virtual environment..."
    pip install terraform-local
}

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env file. Please edit it with your LocalStack auth token."
fi

# Install dependencies
npm install

# Initialize Terraform
cd terraform
../.venv/bin/tflocal init

echo "Local development environment setup complete!" 