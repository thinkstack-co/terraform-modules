#!/usr/bin/env bash
set -euo pipefail

# Build a Graphviz Lambda Layer for x86_64 on Amazon Linux 2 and output graphviz-layer.zip
# Requires Docker.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$SCRIPT_DIR/out"
LAYER_ZIP="$OUT_DIR/graphviz-layer.zip"

mkdir -p "$OUT_DIR"

# Clean previous build
rm -f "$LAYER_ZIP"

# Build inside Amazon Linux 2 to match the Lambda execution environment
# We install graphviz and package required binaries and libraries under /opt

docker run --platform linux/amd64 --rm -i \
  -v "$OUT_DIR":/workspace/out \
  public.ecr.aws/amazonlinux/amazonlinux:2023 bash -s <<'INNER'
set -euo pipefail
# Install packages on Amazon Linux 2023 (dnf)
dnf -y install graphviz zip which

mkdir -p /opt/bin /opt/lib64

# Copy primary executables
for bin in dot neato twopi circo fdp sfdp osage unflatten; do
  if command -v "$bin" >/dev/null 2>&1; then
    cp -v "$(command -v "$bin")" /opt/bin/ || true
  fi
done

# Copy dependent libraries for dot (most comprehensive)
if command -v dot >/dev/null 2>&1; then
  echo "Collecting shared libraries for dot..."
  ldd "$(command -v dot)" | awk '{print $3}' | grep -E "^/" | xargs -I{} cp -v {} /opt/lib64/ || true
fi

# Copy common Graphviz libs (best effort)
for lib in libgvc libcdt libcgraph libpathplan libxdot libexpat libz libpng libjpeg; do
  cp -v /usr/lib64/${lib}* /opt/lib64/ 2>/dev/null || true
done

# Create the layer zip with /opt
cd /opt
zip -r9 /workspace/out/graphviz-layer.zip .
INNER

echo "Created layer: $LAYER_ZIP"
