#!/bin/bash
set -e

# Navigate to the script directory
cd "$(dirname "$0")"

# Copy the required files from the parent directory
echo "Copying Lambda function and requirements..."
cp ../lambda_function.py ../requirements.txt ./

echo "Building Docker image for Lambda packaging..."
docker build -t aws-config-lambda-builder .

echo "Creating Lambda package..."
docker run --rm -v "$(pwd)/../":/output aws-config-lambda-builder

echo "Cleaning up temporary files..."
rm -f lambda_function.py requirements.txt

echo "Lambda package created at: $(pwd)/../lambda_package.zip"
echo "You can now commit this package to your repository."
