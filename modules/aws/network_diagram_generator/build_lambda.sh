#!/bin/bash

# Build script for AWS Network Diagram Generator Lambda function
# This script packages the Lambda function with all required dependencies

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LAMBDA_DIR="${SCRIPT_DIR}/lambda"
BUILD_DIR="${SCRIPT_DIR}/build"
PACKAGE_DIR="${BUILD_DIR}/package"

echo "Building Lambda package for Network Diagram Generator..."

# Clean up previous builds
rm -rf "${BUILD_DIR}"
mkdir -p "${PACKAGE_DIR}"

# Copy Lambda function code
cp "${LAMBDA_DIR}/main.py" "${PACKAGE_DIR}/"

# Install Python dependencies
echo "Installing Python dependencies..."
docker run --rm \
  -v "${PACKAGE_DIR}":/var/task \
  -v "${LAMBDA_DIR}":/src \
  public.ecr.aws/sam/build-python3.11:latest \
  /bin/bash -c "
    pip install --target /var/task -r /src/requirements.txt
    # Copy graphviz binary dependencies
    cp /usr/bin/dot /var/task/
    cp /usr/bin/neato /var/task/
    cp /usr/bin/fdp /var/task/
    cp /usr/bin/sfdp /var/task/
    cp /usr/bin/twopi /var/task/
    cp /usr/bin/circo /var/task/
    # Copy required libraries
    mkdir -p /var/task/lib
    cp -r /usr/lib64/graphviz /var/task/lib/
    cp /usr/lib64/libgvc.so* /var/task/lib/
    cp /usr/lib64/libcgraph.so* /var/task/lib/
    cp /usr/lib64/libcdt.so* /var/task/lib/
    cp /usr/lib64/libpathplan.so* /var/task/lib/
    cp /usr/lib64/libexpat.so* /var/task/lib/
    cp /usr/lib64/libz.so* /var/task/lib/
    # Set executable permissions
    chmod +x /var/task/dot /var/task/neato /var/task/fdp /var/task/sfdp /var/task/twopi /var/task/circo
  "

# Create deployment package
echo "Creating deployment package..."
cd "${PACKAGE_DIR}"
zip -r9 "${SCRIPT_DIR}/lambda.zip" .

# Clean up
cd "${SCRIPT_DIR}"
rm -rf "${BUILD_DIR}"

echo "Lambda package created: ${SCRIPT_DIR}/lambda.zip"
echo "You can now run 'terraform apply' to deploy the module."
