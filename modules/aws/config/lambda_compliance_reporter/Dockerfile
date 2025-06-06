# NOTE: When building Lambda deployment packages with native dependencies, always use the x86_64 architecture for AWS Lambda compatibility unless you are explicitly deploying to arm64 Lambdas.

FROM amazonlinux:2023

# Install Python 3.12, pip, and zip
RUN dnf -y update && \
    dnf -y install python3.12 python3.12-pip zip && \
    dnf clean all

WORKDIR /build

COPY requirements.txt .
COPY lambda_function.py .

RUN python3.12 -m pip install -r requirements.txt -t . && \
    zip -r9 /build/lambda_package.zip .
