#!/bin/bash
set -e

# Create a Docker container to build the Graphviz binaries for Lambda
cat > Dockerfile.graphviz << 'EOF'
FROM amazonlinux:2

# Install dependencies
RUN yum update -y && \
    yum install -y \
    gcc \
    make \
    wget \
    tar \
    gzip \
    zip \
    pkgconfig \
    cairo-devel \
    expat-devel \
    freetype-devel \
    pango-devel \
    zlib-devel

# Download and install Graphviz
WORKDIR /tmp
RUN wget https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/7.1.0/graphviz-7.1.0.tar.gz && \
    tar -xzf graphviz-7.1.0.tar.gz && \
    cd graphviz-7.1.0 && \
    ./configure --prefix=/opt && \
    make && \
    make install

# Create the Lambda Layer structure
RUN mkdir -p /layer/bin /layer/lib /layer/include && \
    cp /opt/bin/dot /layer/bin/ && \
    cp -r /opt/lib/* /layer/lib/ && \
    cp -r /opt/include/* /layer/include/

# Create the layer zip file
WORKDIR /layer
RUN zip -r /graphviz-layer.zip .

# Output the layer
CMD cp /graphviz-layer.zip /output/
EOF

# Build the Docker image
docker build -t graphviz-lambda-layer -f Dockerfile.graphviz .

# Run the container to get the layer
docker run --rm -v "$(pwd):/output" graphviz-lambda-layer

# Clean up
rm Dockerfile.graphviz

echo "Graphviz layer created at graphviz-layer.zip"
