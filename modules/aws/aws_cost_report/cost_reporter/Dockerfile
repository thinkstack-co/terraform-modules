# NOTE: When building Lambda deployment packages with native dependencies, always use the x86_64 architecture for AWS Lambda compatibility unless you are explicitly deploying to arm64 Lambdas.
# Example Docker build command for x86_64 Lambda compatibility:
# docker run --platform linux/amd64 --rm -v "$PWD":/var/task public.ecr.aws/sam/build-python3.12 pip install -r requirements.txt -t ./package

FROM public.ecr.aws/sam/build-python3.12:1.138.0
# checkov:skip=CKV_DOCKER_2: build-only image that packages a Lambda zip; never run as a container, so HEALTHCHECK is inapplicable
# checkov:skip=CKV_DOCKER_3: build-only image; runs only at build time to produce lambda_package.zip, no long-running process to de-privilege

WORKDIR /build

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt -t .

COPY lambda_function.py .

RUN find . -type d -name '*.dist-info' -exec rm -rf {} + && \
    find . -type d -name '__pycache__' -exec rm -rf {} + && \
    zip -r9 /build/lambda_package.zip .
