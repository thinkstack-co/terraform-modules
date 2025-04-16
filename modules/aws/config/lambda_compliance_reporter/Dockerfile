FROM amazonlinux:2

# Install Python 3.8, pip, and zip using amazon-linux-extras
RUN yum -y update && \
    amazon-linux-extras enable python3.8 && \
    yum -y install python38 python38-pip zip && \
    yum clean all

WORKDIR /build

COPY requirements.txt .
COPY lambda_function.py .

RUN /usr/bin/python3.8 -m pip install -r requirements.txt -t . && \
    zip -r9 /build/lambda_package.zip .
