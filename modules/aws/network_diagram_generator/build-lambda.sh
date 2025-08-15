#!/bin/bash
# Build script for Lambda deployment package
# This script must be run locally with Docker installed before committing changes

set -e

echo "Building Lambda deployment package..."
cd lambda

# Build the Docker image
docker build --platform linux/amd64 -t network-diagram-lambda .

# Run the container and extract the package
docker run --platform linux/amd64 --rm -v "$(pwd)":/output network-diagram-lambda cp /build/lambda_package.zip /output/

echo "Lambda package built successfully: lambda/lambda_package.zip"
echo "Package size: $(du -h lambda_package.zip | cut -f1)"

cd ..
echo "Done! Remember to commit the updated lambda_package.zip to the repository."
