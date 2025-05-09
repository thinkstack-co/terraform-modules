# Lambda Cost Reporter - Build & Deploy

This directory contains the Lambda function source code and build instructions for the AWS Cost Reporter module.

## Build Locally (for ZIP Deployment)

1. **Build with Docker** (recommended, matches Lambda environment):
   ```sh
   docker build -t cost-reporter-build .
   docker run --rm -v $(pwd):/out cost-reporter-build cp /tmp/lambda_package.zip /out/lambda_package.zip
   ```
   This will produce `lambda_package.zip` in this directory, ready for upload via Terraform.

2. **Manual (if you have Python 3.12 and pip):**
   ```sh
   pip install --target . -r requirements.txt
   zip -r lambda_package.zip .
   ```

## Deploy with Terraform
- Place `lambda_package.zip` in this directory.
- The Terraform module will use this ZIP for the Lambda function code.

## Python Dependencies
- boto3
- fpdf

## Notes
- The Dockerfile ensures all dependencies are built for the correct Lambda runtime (Python 3.12).
- If you add more dependencies, update `requirements.txt` and rebuild the ZIP.
