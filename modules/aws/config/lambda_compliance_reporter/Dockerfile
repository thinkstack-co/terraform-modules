# NOTE: When building Lambda deployment packages with native dependencies, always use the x86_64 architecture for AWS Lambda compatibility unless you are explicitly deploying to arm64 Lambdas.
# Example Docker build command for x86_64 Lambda compatibility:
# docker run --platform linux/amd64 --rm -v "$PWD":/var/task public.ecr.aws/sam/build-python3.12 pip install -r requirements.txt -t ./package

FROM amazonlinux:2

# Install Python 3.8, pip, and zip using amazon-linux-extras
RUN yum -y update && \
    amazon-linux-extras enable python3.8 && \
    yum -y install python38-3.8.16-1.amzn2 python38-pip-20.2.2-1.amzn2 zip-3.0-23.amzn2.0.2 && \
    yum clean all

WORKDIR /build

COPY requirements.txt .
COPY lambda_function.py .

RUN /usr/bin/python3.8 -m pip install -r requirements.txt -t . && \
    zip -r9 /build/lambda_package.zip .
