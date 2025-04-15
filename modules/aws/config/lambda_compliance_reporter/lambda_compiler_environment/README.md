# Lambda Function Compiler Environment

This directory contains the tools needed to build the AWS Config Compliance Reporter Lambda function package in a compatible environment.

## Purpose

The Lambda function requires dependencies like `reportlab` that include native code components. These must be compiled in a Linux environment to ensure compatibility with the AWS Lambda runtime.

## Contents

- `Dockerfile`: Defines a Python 3.9 environment for building the Lambda package
- `build_lambda.sh`: Script to automate the build process

## Usage

To rebuild the Lambda package:

1. Navigate to this directory
2. Run the build script:
   ```bash
   ./build_lambda.sh
   ```
3. The script will:
   - Copy the Lambda function and requirements from the parent directory
   - Build a Docker container with the necessary environment
   - Install dependencies and create the Lambda package
   - Copy the package back to the parent directory
   - Clean up temporary files

## When to Use

Rebuild the Lambda package when:
- You've updated the Lambda function code
- You've changed the dependencies in requirements.txt
- You need to ensure compatibility with AWS Lambda

This approach ensures the module remains self-contained and can be used directly from GitHub by child modules, following the opt-in architecture pattern where resources are only created when explicitly enabled.
