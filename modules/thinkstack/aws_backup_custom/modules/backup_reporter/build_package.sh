#!/bin/bash

# Build script for AWS Backup Reporter Lambda package
# This script creates a clean Lambda deployment package with dependencies in a separate package folder

set -e

echo "Building AWS Backup Reporter Lambda package..."

# Clean up any existing package
rm -rf package/*
rm -f lambda_package.zip

# Install Python dependencies into package folder
echo "Installing Python dependencies..."
docker run --rm --platform linux/amd64 \
  -v "$(pwd)":/var/task \
  public.ecr.aws/sam/build-python3.12 \
  /bin/bash -c "pip install -r requirements.txt -t package/"

# Create the Lambda package zip file
echo "Creating Lambda package..."
cd package
zip -r ../lambda_package.zip . -x "*.pyc" "__pycache__/*"
cd ..

# Add the Lambda function code to the zip
zip -g lambda_package.zip lambda_function.py

echo "Lambda package created successfully: lambda_package.zip"
echo "Package size: $(du -h lambda_package.zip | cut -f1)"
