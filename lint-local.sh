#!/bin/bash
# Local linting script for terraform-modules
# This script runs all the linters that GitHub Super-Linter runs
# Usage: ./lint-local.sh [path]  # defaults to current directory

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get target directory (default to current directory)
TARGET_DIR="${1:-.}"

echo "🔍 Starting local linting for: $TARGET_DIR"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Track overall status
FAILED=0

# Python linting
echo -e "\n${YELLOW}Python Linting:${NC}"

# Find Python files (excluding common package/vendor directories)
PYTHON_FILES=$(find "$TARGET_DIR" -name "*.py" -type f 2>/dev/null | \
    grep -v __pycache__ | \
    grep -v .venv | \
    grep -v '/package/' | \
    grep -v '/packages/' | \
    grep -v '/vendor/' | \
    grep -v '/node_modules/' | \
    grep -v '/.tox/' | \
    grep -v '/dist/' | \
    grep -v '/build/' || true)

if [ -n "$PYTHON_FILES" ]; then
    if command_exists black; then
        echo "Running Black formatter..."
        # Process files in batches to avoid command line length limits
        if echo "$PYTHON_FILES" | xargs -n 50 black --check --line-length 120; then
            echo -e "${GREEN}✓ Black passed${NC}"
        else
            echo -e "${RED}✗ Black failed - run 'black --line-length 120' on the files${NC}"
            FAILED=1
        fi
    else
        echo -e "${RED}Black not installed - run: pip install black${NC}"
    fi

    if command_exists isort; then
        echo "Running isort..."
        if echo "$PYTHON_FILES" | xargs -n 50 isort --check-only --profile black --line-length 120; then
            echo -e "${GREEN}✓ isort passed${NC}"
        else
            echo -e "${RED}✗ isort failed - run 'isort --profile black --line-length 120' on the files${NC}"
            FAILED=1
        fi
    else
        echo -e "${RED}isort not installed - run: pip install isort${NC}"
    fi

    if command_exists flake8; then
        echo "Running Flake8..."
        if echo "$PYTHON_FILES" | xargs -n 50 flake8 --max-line-length=120 --extend-ignore=E203; then
            echo -e "${GREEN}✓ Flake8 passed${NC}"
        else
            echo -e "${RED}✗ Flake8 failed${NC}"
            FAILED=1
        fi
    else
        echo -e "${RED}Flake8 not installed - run: pip install flake8${NC}"
    fi

    if command_exists mypy; then
        echo "Running mypy..."
        if echo "$PYTHON_FILES" | xargs -n 50 mypy --ignore-missing-imports --no-strict-optional; then
            echo -e "${GREEN}✓ mypy passed${NC}"
        else
            echo -e "${YELLOW}⚠ mypy warnings (non-critical)${NC}"
        fi
    else
        echo -e "${RED}mypy not installed - run: pip install mypy${NC}"
    fi

    if command_exists pylint; then
        echo "Running pylint..."
        if echo "$PYTHON_FILES" | xargs -n 50 pylint --max-line-length=120 --disable=C0114,C0115,C0116,R0903,R0913,W0613; then
            echo -e "${GREEN}✓ pylint passed${NC}"
        else
            echo -e "${YELLOW}⚠ pylint warnings${NC}"
        fi
    else
        echo -e "${RED}pylint not installed - run: pip install pylint${NC}"
    fi
else
    echo "No Python files found"
fi

# Terraform linting
echo -e "\n${YELLOW}Terraform Linting:${NC}"

# Find Terraform files
TF_FILES=$(find "$TARGET_DIR" -name "*.tf" -type f 2>/dev/null || true)

if [ -n "$TF_FILES" ]; then
    if command_exists tflint; then
        echo "Running tflint..."
        # Run tflint in each directory containing .tf files
        echo "$TF_FILES" | xargs -n1 dirname | sort -u | while read -r dir; do
            echo "  Checking $dir..."
            if (cd "$dir" && tflint --format=compact); then
                echo -e "${GREEN}  ✓ tflint passed for $dir${NC}"
            else
                echo -e "${RED}  ✗ tflint failed for $dir${NC}"
                FAILED=1
            fi
        done
    else
        echo -e "${RED}tflint not installed - run: brew install tflint${NC}"
    fi
else
    echo "No Terraform files found"
fi

# Dockerfile linting
echo -e "\n${YELLOW}Dockerfile Linting:${NC}"

# Find Dockerfiles
DOCKERFILES=$(find "$TARGET_DIR" -name "Dockerfile*" -type f 2>/dev/null || true)

if [ -n "$DOCKERFILES" ]; then
    if command_exists hadolint; then
        echo "Running hadolint..."
        echo "$DOCKERFILES" | while read -r dockerfile; do
            if hadolint "$dockerfile"; then
                echo -e "${GREEN}✓ hadolint passed for $dockerfile${NC}"
            else
                echo -e "${RED}✗ hadolint failed for $dockerfile${NC}"
                FAILED=1
            fi
        done
    else
        echo -e "${RED}hadolint not installed - run: brew install hadolint${NC}"
    fi
else
    echo "No Dockerfiles found"
fi

# Secret scanning
echo -e "\n${YELLOW}Secret Scanning:${NC}"

if command_exists gitleaks; then
    echo "Running gitleaks..."
    if (cd "$TARGET_DIR" && gitleaks detect --verbose); then
        echo -e "${GREEN}✓ No secrets detected${NC}"
    else
        echo -e "${RED}✗ Potential secrets found!${NC}"
        FAILED=1
    fi
else
    echo -e "${RED}gitleaks not installed - run: brew install gitleaks${NC}"
fi

# Duplicate code detection
echo -e "\n${YELLOW}Duplicate Code Detection:${NC}"

if command_exists jscpd; then
    echo "Running jscpd..."
    # Create temporary config if .jscpd.json doesn't exist
    if [ ! -f "$TARGET_DIR/.jscpd.json" ] && [ ! -f "$(dirname "$TARGET_DIR")/.jscpd.json" ]; then
        TEMP_CONFIG=$(mktemp)
        cat > "$TEMP_CONFIG" << 'EOF'
{
  "threshold": 5,
  "reporters": ["console"],
  "ignore": [
    "**/node_modules/**",
    "**/.git/**",
    "**/package/**",
    "**/packages/**",
    "**/vendor/**",
    "**/.venv/**",
    "**/build/**",
    "**/dist/**",
    "**/*.min.js",
    "**/*.min.css"
  ],
  "minLines": 5,
  "minTokens": 70,
  "output": "."
}
EOF
        if (cd "$TARGET_DIR" && jscpd . --config "$TEMP_CONFIG" --silent); then
            echo -e "${GREEN}✓ No significant code duplication found${NC}"
        else
            echo -e "${YELLOW}⚠ Code duplication detected (non-critical)${NC}"
        fi
        rm -f "$TEMP_CONFIG"
    else
        if (cd "$TARGET_DIR" && jscpd . --silent); then
            echo -e "${GREEN}✓ No significant code duplication found${NC}"
        else
            echo -e "${YELLOW}⚠ Code duplication detected (non-critical)${NC}"
        fi
    fi
else
    echo -e "${RED}jscpd not installed - run: npm install -g jscpd${NC}"
fi

# Summary
echo -e "\n${YELLOW}=================${NC}"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All critical linting passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some linting checks failed${NC}"
    echo -e "${YELLOW}Fix the issues above and run this script again${NC}"
    exit 1
fi