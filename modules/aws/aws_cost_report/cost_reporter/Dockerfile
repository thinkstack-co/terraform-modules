# Lambda build Dockerfile for cost_reporter
# NOTE: Always build this image for x86_64 (amd64) architecture to ensure Lambda compatibility, even when running Docker on a Mac (which defaults to ARM64). Use the --platform flag as shown below.
# Example Docker build command for x86_64 Lambda compatibility:
# docker build --platform linux/amd64 -t cost_reporter_lambda_build .
# docker run --rm -v "$PWD":/out cost_reporter_lambda_build cp /build/lambda_package.zip /out/lambda_package.zip

FROM amazonlinux:2

# Install Python 3.8, pip, and zip using amazon-linux-extras
RUN yum -y update && \
    amazon-linux-extras enable python3.8 && \
    yum -y install python38 python38-pip zip && \
    yum clean all

WORKDIR /build

COPY requirements.txt .
COPY lambda_function.py .

RUN /usr/bin/python3.8 -m pip install --no-cache-dir -r requirements.txt -t . && \
    # remove pip metadata and caches to slim package
    find . -type d -name '*.dist-info' -exec rm -rf {} + && \
    find . -type d -name '__pycache__' -exec rm -rf {} + && \
    zip -r9 /build/lambda_package.zip .
