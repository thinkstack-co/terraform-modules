#!/bin/bash

# Individual Linters with Reports for macOS Sequoia 15.6.1
# Runs the same linters as Super-Linter but individually for better reliability

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Individual Linters with Reports${NC}"
echo -e "${BLUE}===============================${NC}"
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker Desktop and try again.${NC}"
    exit 1
fi

# Create reports directory structure
REPORTS_DIR="./reports"
mkdir -p "$REPORTS_DIR/markdownlint"
mkdir -p "$REPORTS_DIR/shellcheck"
mkdir -p "$REPORTS_DIR/python-flake8"
mkdir -p "$REPORTS_DIR/python-black"
mkdir -p "$REPORTS_DIR/hadolint"
mkdir -p "$REPORTS_DIR/bash"
mkdir -p "$REPORTS_DIR/jscpd"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
MAIN_REPORT="$REPORTS_DIR/linting_summary_$TIMESTAMP.txt"

echo -e "${YELLOW}Reports will be saved to: $REPORTS_DIR${NC}"
echo ""

# Initialize report
{
    echo "Linting Report - $(date)"
    echo "========================"
    echo ""
} > "$MAIN_REPORT"

failed_linters=0
total_linters=0

# Function to run a linter and capture results
run_linter() {
    local linter_name="$1"
    local linter_command="$2"
    local report_subdir="$3"
    
    total_linters=$((total_linters + 1))
    echo -e "${YELLOW}Running $linter_name...${NC}"
    
    local linter_report="$REPORTS_DIR/$report_subdir/${report_subdir}_report_$TIMESTAMP.txt"
    
    {
        echo "$linter_name Report - $(date)"
        echo "=================================="
        echo "Command: $linter_command"
        echo ""
    } > "$linter_report"
    
    {
        echo "=== $linter_name Results ==="
        echo "Report: $linter_report"
        echo ""
    } >> "$MAIN_REPORT"
    
    if eval "$linter_command" >> "$linter_report" 2>&1; then
        echo -e "${GREEN}✓ $linter_name passed${NC}"
        echo "✓ PASSED" >> "$MAIN_REPORT"
        echo "✓ PASSED" >> "$linter_report"
    else
        echo -e "${RED}✗ $linter_name failed${NC}"
        echo "✗ FAILED" >> "$MAIN_REPORT"
        echo "✗ FAILED" >> "$linter_report"
        failed_linters=$((failed_linters + 1))
    fi
    
    echo "" >> "$MAIN_REPORT"
    echo ""
}

# Run Markdownlint (process files individually to avoid stack overflow)
echo -e "${YELLOW}Running Markdownlint...${NC}"
markdownlint_report="$REPORTS_DIR/markdownlint/markdownlint_report_$TIMESTAMP.txt"
{
    echo "Markdownlint Report - $(date)"
    echo "=================================="
    echo ""
} > "$markdownlint_report"

markdownlint_failed=0
find . -name "*.md" -not -path "*/.terraform/*" -not -path "./reports/*" | while read -r md_file; do
    if ! docker run --rm -v "$(pwd)":/workdir davidanson/markdownlint-cli2:v0.8.1 "$md_file" --config .markdownlint.json >> "$markdownlint_report" 2>&1; then
        markdownlint_failed=1
    fi
done

if [ $markdownlint_failed -eq 0 ]; then
    echo -e "${GREEN}✓ Markdownlint passed${NC}"
    echo "✓ PASSED" >> "$markdownlint_report"
else
    echo -e "${RED}✗ Markdownlint failed${NC}"
    echo "✗ FAILED" >> "$markdownlint_report"
    failed_linters=$((failed_linters + 1))
fi
total_linters=$((total_linters + 1))

# Run ShellCheck (find shell files properly)
echo -e "${YELLOW}Running ShellCheck...${NC}"
shellcheck_report="$REPORTS_DIR/shellcheck/shellcheck_report_$TIMESTAMP.txt"
{
    echo "ShellCheck Report - $(date)"
    echo "=================================="
    echo ""
} > "$shellcheck_report"

shell_files=$(find . -name "*.sh" -not -path "*/.terraform/*" -not -path "./reports/*")
if [ -n "$shell_files" ]; then
    shellcheck_failed=0
    echo "$shell_files" | while read -r shell_file; do
        echo "Checking: $shell_file" >> "$shellcheck_report"
        if ! docker run --rm -v "$(pwd)":/mnt koalaman/shellcheck:stable "/mnt/$shell_file" >> "$shellcheck_report" 2>&1; then
            shellcheck_failed=1
        fi
        echo "" >> "$shellcheck_report"
    done
    
    if [ $shellcheck_failed -eq 0 ]; then
        echo -e "${GREEN}✓ ShellCheck passed${NC}"
        echo "✓ PASSED" >> "$shellcheck_report"
    else
        echo -e "${RED}✗ ShellCheck failed${NC}"
        echo "✗ FAILED" >> "$shellcheck_report"
        failed_linters=$((failed_linters + 1))
    fi
else
    echo -e "${BLUE}No shell files found, skipping ShellCheck${NC}"
    echo "No shell files found - SKIPPED" >> "$shellcheck_report"
fi
total_linters=$((total_linters + 1))

# Run Python Flake8
run_linter "Python Flake8" 'docker run --rm -v "$(pwd)":/apps alpine/flake8:latest /apps' "python-flake8"

# Run Python Black (check only, exclude package directories)
echo -e "${YELLOW}Running Python Black...${NC}"
black_report="$REPORTS_DIR/python-black/python-black_report_$TIMESTAMP.txt"
{
    echo "Python Black Report - $(date)"
    echo "=================================="
    echo ""
} > "$black_report"

# Find Python files excluding package directories and virtual environments
python_files=$(find . -name "*.py" -not -path "*/.terraform/*" -not -path "./reports/*" -not -path "*/package/*" -not -path "*/.venv/*")
if [ -n "$python_files" ]; then
    black_failed=0
    echo "$python_files" | while read -r py_file; do
        echo "Checking: $py_file" >> "$black_report"
        if ! docker run --rm -v "$(pwd)":/code pyfound/black:latest black --check --diff "/code/$py_file" >> "$black_report" 2>&1; then
            black_failed=1
        fi
        echo "" >> "$black_report"
    done
    
    if [ $black_failed -eq 0 ]; then
        echo -e "${GREEN}✓ Python Black passed${NC}"
        echo "✓ PASSED" >> "$black_report"
    else
        echo -e "${RED}✗ Python Black failed${NC}"
        echo "✗ FAILED" >> "$black_report"
        failed_linters=$((failed_linters + 1))
    fi
else
    echo -e "${BLUE}No Python files found, skipping Black${NC}"
    echo "No Python files found - SKIPPED" >> "$black_report"
fi
total_linters=$((total_linters + 1))

# Run Hadolint (Dockerfile linter)
echo -e "${YELLOW}Running Hadolint...${NC}"
hadolint_report="$REPORTS_DIR/hadolint/hadolint_report_$TIMESTAMP.txt"
{
    echo "Hadolint Report - $(date)"
    echo "=================================="
    echo ""
} > "$hadolint_report"

dockerfile_files=$(find . -name "Dockerfile" -not -path "*/.terraform/*" -not -path "./reports/*")
if [ -n "$dockerfile_files" ]; then
    hadolint_failed=0
    echo "$dockerfile_files" | while read -r dockerfile; do
        echo "Checking: $dockerfile" >> "$hadolint_report"
        if ! docker run --rm -i hadolint/hadolint < "$dockerfile" >> "$hadolint_report" 2>&1; then
            hadolint_failed=1
        fi
        echo "" >> "$hadolint_report"
    done
    
    if [ $hadolint_failed -eq 0 ]; then
        echo -e "${GREEN}✓ Hadolint passed${NC}"
        echo "✓ PASSED" >> "$hadolint_report"
    else
        echo -e "${RED}✗ Hadolint failed${NC}"
        echo "✗ FAILED" >> "$hadolint_report"
        failed_linters=$((failed_linters + 1))
    fi
else
    echo -e "${BLUE}No Dockerfiles found, skipping Hadolint${NC}"
    echo "No Dockerfiles found - SKIPPED" >> "$hadolint_report"
fi
total_linters=$((total_linters + 1))

# Run Bash linting (using shellcheck on bash files)
echo -e "${YELLOW}Running Bash linting...${NC}"
bash_report="$REPORTS_DIR/bash/bash_report_$TIMESTAMP.txt"
{
    echo "Bash Linting Report - $(date)"
    echo "=================================="
    echo ""
} > "$bash_report"

bash_files=$(find . -name "*.bash" -o -name "*.sh" -not -path "*/.terraform/*" -not -path "./reports/*")
if [ -n "$bash_files" ]; then
    bash_failed=0
    echo "$bash_files" | while read -r bash_file; do
        echo "Checking: $bash_file" >> "$bash_report"
        if ! docker run --rm -v "$(pwd)":/mnt koalaman/shellcheck:stable "/mnt/$bash_file" >> "$bash_report" 2>&1; then
            bash_failed=1
        fi
        echo "" >> "$bash_report"
    done
    
    if [ $bash_failed -eq 0 ]; then
        echo -e "${GREEN}✓ Bash linting passed${NC}"
        echo "✓ PASSED" >> "$bash_report"
    else
        echo -e "${RED}✗ Bash linting failed${NC}"
        echo "✗ FAILED" >> "$bash_report"
        failed_linters=$((failed_linters + 1))
    fi
else
    echo -e "${BLUE}No bash files found, skipping Bash linting${NC}"
    echo "No bash files found - SKIPPED" >> "$bash_report"
fi
total_linters=$((total_linters + 1))

# Run JSCPD (Copy-Paste Detection)
echo -e "${YELLOW}Running JSCPD (Copy-Paste Detection)...${NC}"
jscpd_report="$REPORTS_DIR/jscpd/jscpd_report_$TIMESTAMP.txt"
{
    echo "JSCPD Report - $(date)"
    echo "=================================="
    echo ""
} > "$jscpd_report"

# Use jscpd via npx in node Docker image with git
if docker run --rm -v "$(pwd)":/app -w /app node:18-alpine sh -c "apk add --no-cache git && git config --global --add safe.directory /app && npx jscpd --config .jscpd.json" >> "$jscpd_report" 2>&1; then
    echo -e "${GREEN}✓ JSCPD passed${NC}"
    echo "✓ PASSED" >> "$jscpd_report"
else
    echo -e "${RED}✗ JSCPD failed${NC}"
    echo "✗ FAILED" >> "$jscpd_report"
    failed_linters=$((failed_linters + 1))
fi
total_linters=$((total_linters + 1))

# Create summary
SUMMARY_FILE="$REPORTS_DIR/latest_summary.txt"
{
    echo "Linting Summary - $(date)"
    echo "========================"
    echo ""
    echo "Total linters run: $total_linters"
    echo "Failed linters: $failed_linters"
    echo "Passed linters: $((total_linters - failed_linters))"
    echo ""
    
    if [ $failed_linters -eq 0 ]; then
        echo "✅ STATUS: All linters passed!"
    else
        echo "❌ STATUS: $failed_linters linter(s) failed"
        echo ""
        echo "Failed linters:"
        grep "✗ FAILED" "$MAIN_REPORT" | sed 's/✗ FAILED//' | while read -r line; do
            echo "  - $line"
        done
    fi
    
    echo ""
    echo "Full report: $MAIN_REPORT"
} > "$SUMMARY_FILE"

# Final output
echo -e "${BLUE}Linting Summary${NC}"
echo -e "${BLUE}===============${NC}"
if [ $failed_linters -eq 0 ]; then
    echo -e "${GREEN}✅ All $total_linters linters passed successfully!${NC}"
    exit_code=0
else
    echo -e "${RED}❌ $failed_linters out of $total_linters linters failed${NC}"
    exit_code=1
fi

echo ""
echo -e "${BLUE}📄 Full report saved to: $MAIN_REPORT${NC}"
echo -e "${BLUE}📋 Summary saved to: $SUMMARY_FILE${NC}"
echo ""
echo -e "${YELLOW}Quick summary:${NC}"
cat "$SUMMARY_FILE"

exit $exit_code
