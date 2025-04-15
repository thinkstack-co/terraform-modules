FROM amazonlinux:2

# Install Python and development tools
RUN yum update -y && \
    yum install -y python3-pip python3-devel gcc zip && \
    yum clean all

# Set up working directory
WORKDIR /var/task

# Copy requirements and Lambda function
COPY requirements.txt lambda_function.py ./

# Install dependencies
RUN pip3 install -r requirements.txt --target .

# Create the Lambda package
RUN zip -r lambda_package.zip .

# Command to copy the package to the mounted volume
CMD ["cp", "lambda_package.zip", "/output/"]
