# AWS Lambda Deployment Package Builder for Config Compliance Reporter
#
# IMPORTANT: This Dockerfile builds a Lambda deployment package compatible with AWS Lambda's x86_64 architecture.
# Even if you're on an ARM-based machine (like M1/M2 Mac), you must build for x86_64 for Lambda compatibility.
#
# Build Instructions:
# 1. Navigate to this directory in your terminal
# 2. Build the Docker image:
#    docker build --platform linux/amd64 -t lambda-builder .
#
# 3. Extract the Lambda package:
#    docker run --rm -v $(pwd):/output lambda-builder cp /build/lambda_package.zip /output/
#
# 4. The lambda_package.zip will be available in the current directory
#
# NOTE: You will see a platform mismatch warning if building on ARM - this is normal and expected.
# WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8)

FROM amazonlinux:2023
# checkov:skip=CKV_DOCKER_2: build-only image that packages a Lambda zip; never run as a container, so HEALTHCHECK is inapplicable
# checkov:skip=CKV_DOCKER_3: build-only image; runs only at build time to produce lambda_package.zip, no long-running process to de-privilege

# Install Python 3.13, pip, and zip
# hadolint ignore=DL3041
RUN dnf -y update && \
    dnf -y install python3.13 python3.13-pip zip && \
    dnf clean all

WORKDIR /build

COPY requirements.txt .
COPY lambda_function.py .

RUN python3.13 -m pip install --no-cache-dir -r requirements.txt -t . && \
    zip -r9 /build/lambda_package.zip .
