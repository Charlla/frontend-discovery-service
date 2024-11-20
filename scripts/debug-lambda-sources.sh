#!/bin/bash

echo "Checking Lambda source directories..."

LAMBDA_DIR="infrastructure/lambda"
REQUIRED_FILES=("app.js" "package.json")

check_lambda_dir() {
    local dir=$1
    echo "Checking $dir..."
    
    if [ ! -d "$LAMBDA_DIR/$dir" ]; then
        echo "❌ Directory $LAMBDA_DIR/$dir not found"
        return 1
    fi
    
    for file in "${REQUIRED_FILES[@]}"; do
        if [ ! -f "$LAMBDA_DIR/$dir/$file" ]; then
            echo "❌ Required file $file not found in $LAMBDA_DIR/$dir"
            return 1
        fi
    done
    
    echo "✅ $dir checks passed"
    return 0
}

# Check each Lambda function directory
check_lambda_dir "adminApi" || exit 1
check_lambda_dir "consumerApi" || exit 1
check_lambda_dir "stream" || exit 1

echo "All Lambda source checks passed!"

# Show contents of Lambda directories
echo -e "\nLambda source files:"
for dir in adminApi consumerApi stream; do
    echo -e "\n$dir contents:"
    ls -la "$LAMBDA_DIR/$dir"
done 