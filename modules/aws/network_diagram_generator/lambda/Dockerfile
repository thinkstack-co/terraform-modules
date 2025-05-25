FROM public.ecr.aws/lambda/python:3.11

# Install system dependencies
RUN yum install -y zip

WORKDIR ${LAMBDA_TASK_ROOT}

# Copy requirements and install dependencies
COPY requirements.txt .
COPY main.py .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt -t . && \
    # Remove unnecessary files to reduce package size
    find . -type d -name "tests" -exec rm -rf {} + 2>/dev/null || true && \
    find . -type d -name "docs" -exec rm -rf {} + 2>/dev/null || true && \
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true && \
    find . -name "*.pyc" -delete 2>/dev/null || true && \
    find . -name "*.pyo" -delete 2>/dev/null || true && \
    # Remove unnecessary provider resources from diagrams to reduce size
    rm -rf diagrams/azure diagrams/gcp diagrams/k8s diagrams/oci diagrams/onprem \
           diagrams/programming diagrams/saas diagrams/alibabacloud diagrams/firebase \
           diagrams/digitalocean diagrams/elastic diagrams/generic diagrams/ibm \
           diagrams/openstack diagrams/outscale diagrams/custom 2>/dev/null || true

# Create the deployment package
RUN cd ${LAMBDA_TASK_ROOT} && \
    zip -r9 /lambda_package.zip . -x "*.zip"

# Output the package
CMD cp /lambda_package.zip /output/
