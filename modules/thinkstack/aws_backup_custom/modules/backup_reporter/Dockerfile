# NOTE: When building Lambda deployment packages with native dependencies, always use the x86_64 architecture for AWS Lambda compatibility unless you are explicitly deploying to arm64 Lambdas.
# Example Docker build command for x86_64 Lambda compatibility:
# docker run --platform linux/amd64 --rm -v "$PWD":/var/task public.ecr.aws/sam/build-python3.12 pip install -r requirements.txt -t ./package

FROM public.ecr.aws/sam/build-python3.12:1.138.0

WORKDIR /build

# Copy and install requirements
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt -t . && \
    pip3 list

# Copy Lambda function code
COPY lambda_function.py .

RUN find . -type d -name '*.dist-info' -exec rm -rf {} + && \
    find . -type d -name '__pycache__' -exec rm -rf {} + && \
    zip -r9 /build/lambda_package.zip .
