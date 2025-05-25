#!/bin/bash
set -e

cd "$(dirname "$0")"

# Create a Docker container to build the Graphviz binaries for Lambda
cat > Dockerfile.graphviz << 'EOF'
FROM amazonlinux:2

# Install dependencies
RUN yum update -y && \
    yum install -y \
    gcc \
    gcc-c++ \
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
    zlib-devel \
    automake \
    autoconf \
    which

# Verify g++ installation
RUN echo "Checking for g++..." && \
    (which g++ || echo "g++ not found by which") && \
    (g++ --version || echo "g++ --version failed") && \
    echo "PATH is: $PATH"

# Download and install Graphviz
WORKDIR /tmp
RUN wget https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/7.1.0/graphviz-7.1.0.tar.gz && \
    tar -xzf graphviz-7.1.0.tar.gz && \
    cd graphviz-7.1.0 && \
    CXX=g++ ./configure --prefix=/opt && \
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

# Build the Docker image without cache
docker build --no-cache -t graphviz-layer-builder -f Dockerfile.graphviz .

# Run the container to extract the layer package
# Ensure the output directory exists on the host
mkdir -p ./output
docker run --rm --entrypoint /bin/cp -v "$(pwd)/output:/host_output" graphviz-layer-builder /graphviz-layer.zip /host_output/graphviz_layer.zip

# Rename the output file
if [ -f "./output/graphviz_layer.zip" ]; then
  mv ./output/graphviz_layer.zip ./graphviz_layer.zip
  rm -rf ./output
  echo "Graphviz layer built successfully: $(pwd)/graphviz_layer.zip"
  echo "Package size: $(ls -lh graphviz_layer.zip | awk '{print $5}')"
else
  echo "Error: graphviz_layer.zip not found in output."
  exit 1
fi

# Clean up
rm Dockerfile.graphviz
