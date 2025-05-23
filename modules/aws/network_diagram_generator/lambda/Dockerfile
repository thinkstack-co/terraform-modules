FROM public.ecr.aws/sam/build-python3.11:1.100.0

WORKDIR /build

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt -t .

COPY main.py .

# Clean up and zip the package for Lambda deployment (same as cost report module)
RUN find . -type d -name '*.dist-info' -exec rm -rf {} + && \
    find . -type d -name '__pycache__' -exec rm -rf {} + && \
    zip -r9 /lambda_package.zip .
