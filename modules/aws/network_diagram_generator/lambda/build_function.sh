#!/bin/bash
set -e

echo "Building Lambda function package with Docker..."

# Change to the lambda directory
cd "$(dirname "$0")"

# Build the Docker image
docker build -t lambda-builder .

# Run the container to create the package, explicitly using cp as the entrypoint
docker run --rm --entrypoint /bin/cp -v "$(pwd):/output" lambda-builder /lambda_package.zip /output/lambda_package.zip

# Rename the output file to match what Terraform expects
mv lambda_package.zip function.zip

echo "Lambda function package built successfully!"
echo "Package location: $(pwd)/function.zip"
echo "Package size: $(ls -lh function.zip | awk '{print $5}')"
