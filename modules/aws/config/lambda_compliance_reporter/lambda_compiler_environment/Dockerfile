FROM python:3.9-slim

# Install zip
RUN apt-get update && apt-get install -y zip && apt-get clean

# Set up working directory
WORKDIR /build

# Copy requirements and Lambda function
COPY requirements.txt lambda_function.py ./

# Install dependencies
RUN pip install -r requirements.txt -t .

# Create the Lambda package
RUN zip -r lambda_package.zip .

# Command to copy the package to the mounted volume
CMD ["cp", "lambda_package.zip", "/output/"]
