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
