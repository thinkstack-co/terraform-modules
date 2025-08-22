#!/bin/bash

# Super-Linter for macOS Sequoia 15.6.1
# Runs Super-Linter locally using Docker and generates reports

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Super-Linter Local Runner with Reports${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker Desktop and try again.${NC}"
    exit 1
fi

# Create reports directory
REPORTS_DIR="./lint-reports"
mkdir -p "$REPORTS_DIR"
echo -e "${YELLOW}Reports will be saved to: $REPORTS_DIR${NC}"
echo ""

# Generate timestamp for this run
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="$REPORTS_DIR/superlinter_report_$TIMESTAMP.txt"

echo -e "${YELLOW}Running Super-Linter slim...${NC}"
echo ""

# Run Super-Linter with configuration optimized for local development
# Capture both stdout and stderr to the report file
{
    echo "Super-Linter Report - $(date)"
    echo "=================================="
    echo ""
    
    docker run --rm \
        -e RUN_LOCAL=true \
        -e USE_FIND_ALGORITHM=true \
        -e VALIDATE_ALL_CODEBASE=false \
        -e VALIDATE_MARKDOWN=true \
        -e VALIDATE_BASH=true \
        -e VALIDATE_TERRAFORM_TFLINT=true \
        -e VALIDATE_PYTHON_FLAKE8=true \
        -e VALIDATE_PYTHON_BLACK=true \
        -e VALIDATE_DOCKERFILE_HADOLINT=true \
        -e LOG_LEVEL=INFO \
        -e SUPPRESS_POSSUM=true \
        -e FILTER_REGEX_EXCLUDE=".*/.terraform/.*|.*/package/.*|.*/.git/.*" \
        -v "$(pwd)":/tmp/lint \
        ghcr.io/github/super-linter:slim-v5.0.0 2>&1
        
    echo ""
    echo "Report generated at: $(date)"
} | tee "$REPORT_FILE"

# Also create a summary report
SUMMARY_FILE="$REPORTS_DIR/latest_summary.txt"
{
    echo "Super-Linter Summary - $(date)"
    echo "=============================="
    echo ""
    
    # Extract error counts from the report
    if grep -q "ERROR" "$REPORT_FILE"; then
        echo "ERRORS FOUND:"
        grep "ERROR" "$REPORT_FILE" | head -20
        echo ""
    fi
    
    if grep -q "WARN" "$REPORT_FILE"; then
        echo "WARNINGS FOUND:"
        grep "WARN" "$REPORT_FILE" | head -10
        echo ""
    fi
    
    # Check final status
    if grep -q "All file(s) linted successfully" "$REPORT_FILE"; then
        echo "✅ STATUS: All linters passed!"
    else
        echo "❌ STATUS: Some linters failed - check full report for details"
    fi
    
    echo ""
    echo "Full report: $REPORT_FILE"
} > "$SUMMARY_FILE"

echo ""
echo -e "${GREEN}Super-Linter execution completed!${NC}"
echo -e "${BLUE}📄 Full report saved to: $REPORT_FILE${NC}"
echo -e "${BLUE}📋 Summary saved to: $SUMMARY_FILE${NC}"
echo ""
echo -e "${YELLOW}Quick summary:${NC}"
cat "$SUMMARY_FILE"
