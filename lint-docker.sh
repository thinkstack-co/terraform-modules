#!/bin/bash
# Docker-based local linting script that matches CI environment
# Uses GitHub Super-Linter to ensure consistency with CI

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables for arguments
TARGET_DIR="."
LINTER_OPTION=""
ABSOLUTE_PATH="$(pwd)"

# Create lint_reports directory structure
REPORTS_DIR="$ABSOLUTE_PATH/lint_reports"
mkdir -p "$REPORTS_DIR"/{terraform,python,docker,secrets,duplicates,configs}

# Clean up old reports
find "$REPORTS_DIR" -name "*.log" -o -name "*.md" -o -name "*.json" | xargs rm -f 2>/dev/null || true

echo -e "${BLUE}🔍 Starting Super-Linter for: $TARGET_DIR${NC}"
echo -e "${BLUE}📝 Reports will be saved to: $REPORTS_DIR${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Function to parse Super-Linter output and create formatted report
create_formatted_report() {
    local log_file=$1
    local report_file=$2
    local linter_name=$3
    
    # Create markdown report
    echo "# $linter_name Lint Report" > "$report_file"
    echo "" >> "$report_file"
    echo "Generated on: $(date)" >> "$report_file"
    echo "Repository: $(basename "$ABSOLUTE_PATH")" >> "$report_file"
    echo "" >> "$report_file"
    
    # Extract errors and warnings from log
    local error_count=0
    local warning_count=0
    
    # Create temporary file for parsing
    local temp_file=$(mktemp)
    
    # Extract relevant error lines - specifically look for file paths with line numbers
    # For Python: look for .py: patterns (flake8, mypy errors)
    # For black: look for specific error patterns
    grep -E "(\.py:[0-9]+:|\.tf:[0-9]+:|ERROR.*\.py|Found errors in \[)" "$log_file" 2>/dev/null | \
    grep -v "ERROR SUMMARY" | \
    grep -v "not a git repository" | \
    grep -v "Validate ENV files" | \
    grep -v "was linted with.*successfully" > "$temp_file" || true
    
    if [ -s "$temp_file" ]; then
        echo "## 🔍 Issues Found" >> "$report_file"
        echo "" >> "$report_file"
        
        # Group by file
        local current_file=""
        local black_error_file=""
        
        while IFS= read -r line; do
            # Check for file context line (e.g., "File:[/tmp/lint/path/to/file.py]")
            if [[ "$line" =~ File:\[([^\]]+\.py)\] ]]; then
                black_error_file="${BASH_REMATCH[1]}"
                black_error_file="${black_error_file#/tmp/lint/}"
                continue
            fi
            
            # Check for black error indicator
            if [[ "$line" =~ "Found errors in \[black\]" ]] && [[ -n "$black_error_file" ]]; then
                # We have a black error for the file stored in black_error_file
                continue
            fi
            
            # Try to extract file path with more flexible regex
            # Match patterns like: /path/to/file.py:line:col: message
            if [[ "$line" =~ \.py:[0-9]+:[0-9]+: ]] || [[ "$line" =~ \.tf:[0-9]+:[0-9]+: ]]; then
                # Parse using cut for more reliable extraction
                file=$(echo "$line" | cut -d: -f1)
                line_num=$(echo "$line" | cut -d: -f2)
                col_num=$(echo "$line" | cut -d: -f3)
                message=$(echo "$line" | cut -d: -f4- | sed 's/^ *//')
                
                # Remove /tmp/lint/ prefix if present
                file="${file#/tmp/lint/}"
                
                if [[ "$file" != "$current_file" ]]; then
                    if [[ -n "$current_file" ]]; then
                        echo "" >> "$report_file"
                    fi
                    echo "### 📄 \`$file\`" >> "$report_file"
                    current_file="$file"
                fi
                
                echo -n "- **Line $line_num" >> "$report_file"
                if [ -n "$col_num" ]; then
                    echo -n ", Column $col_num" >> "$report_file"
                fi
                echo ":** $message" >> "$report_file"
                
                if [[ "$line" =~ ERROR ]]; then
                    ((error_count++))
                else
                    ((warning_count++))
                fi
            # Handle black formatting errors
            elif [[ -n "$black_error_file" ]] && [[ "$line" =~ "Error code:" ]]; then
                if [[ "$black_error_file" != "$current_file" ]]; then
                    if [[ -n "$current_file" ]]; then
                        echo "" >> "$report_file"
                    fi
                    echo "### 📄 \`$black_error_file\`" >> "$report_file"
                    current_file="$black_error_file"
                fi
                echo "- **Formatting Error:** File needs black formatting" >> "$report_file"
                ((error_count++))
                black_error_file=""
            fi
        done < "$temp_file"
        
        echo "" >> "$report_file"
        echo "## 📊 Summary" >> "$report_file"
        echo "- **Errors:** $error_count" >> "$report_file"
        echo "- **Warnings:** $warning_count" >> "$report_file"
    else
        echo "## ✅ No Issues Found" >> "$report_file"
        echo "" >> "$report_file"
        echo "All $linter_name checks passed successfully!" >> "$report_file"
    fi
    
    rm -f "$temp_file"
    
    # Add raw log reference
    echo "" >> "$report_file"
    echo "---" >> "$report_file"
    echo "_Full log available at: \`${log_file#$ABSOLUTE_PATH/}\`_" >> "$report_file"
}

# Function to run JSCPD linter with enhanced reporting
run_jscpd_linter() {
    echo -e "\n${YELLOW}Running Duplicate Code Detection with detailed output...${NC}"
    
    # Create log and report files
    local log_file="$REPORTS_DIR/duplicates/duplicate-code.log"
    local report_file="$REPORTS_DIR/duplicates/duplicate-code.md"
    local json_file="$REPORTS_DIR/duplicates/duplicate-code.json"
    
    # Run JSCPD with detailed output
    docker run --rm --name "super-linter-jscpd-$(date +%s)" \
        -e RUN_LOCAL=true \
        -e LOG_LEVEL=INFO \
        -e LOG_FILE=super-linter.log \
        -e VALIDATE_JSCPD=true \
        -e JSCPD_CONFIG_FILE=.jscpd.json \
        -e JSCPD_CONFIG_THRESHOLD=5 \
        -e FILTER_REGEX_INCLUDE=".*" \
        -e FILTER_REGEX_EXCLUDE="(.*\.git/.*|.*node_modules/.*)" \
        -e LINTER_RULES_PATH=/ \
        -e DEFAULT_WORKSPACE=/ \
        -e TAP_REPORTER=true \
        -e GITHUB_WORKSPACE=/tmp/lint \
        -e GITHUB_REPOSITORY=terraform-modules \
        -v "$(pwd)":/tmp/lint \
        ghcr.io/super-linter/super-linter:v5 \
        2>&1 | tee "$log_file"
        
    local exit_code=${PIPESTATUS[0]}
    
    # Extract detailed JSCPD information and create a better report
    echo "# Duplicate Code Detection Lint Report" > "$report_file"
    echo "" >> "$report_file"
    echo "Generated on: $(date)" >> "$report_file"
    echo "Repository: $(basename "$ABSOLUTE_PATH")" >> "$report_file"
    echo "" >> "$report_file"
    
    # Extract duplicate code information from the log
    if grep -q "Found [1-9]" "$log_file"; then
        # Found duplicates
        echo "## 🔍 Issues Found" >> "$report_file"
        echo "" >> "$report_file"
        
        # Extract duplication percentage
        local dup_percent=$(grep -o "duplicates ([0-9.]\+%)" "$log_file" | grep -o "[0-9.]\+" || echo "unknown")
        echo "### Duplication Rate: ${dup_percent}%" >> "$report_file"
        echo "" >> "$report_file"
        
        # Extract clone count
        local clone_count=$(grep -o "Found [0-9]\+ clones" "$log_file" | grep -o "[0-9]\+" || echo "unknown")
        echo "### Number of Clones: $clone_count" >> "$report_file"
        echo "" >> "$report_file"
        
        # Create a detailed report by running jscpd directly with more verbose output
        echo "### Detailed Clone Information" >> "$report_file"
        echo "" >> "$report_file"
        echo "To see detailed information about each clone, run the following command:" >> "$report_file"
        echo '```bash' >> "$report_file"
        echo "cd $ABSOLUTE_PATH && npx jscpd . --config .jscpd.json --reporters console --verbose" >> "$report_file"
        echo '```' >> "$report_file"
        echo "" >> "$report_file"
        
        # Add troubleshooting information
        echo "### Troubleshooting" >> "$report_file"
        echo "" >> "$report_file"
        echo "If you're having trouble running the above command with npx, you can try:" >> "$report_file"
        echo "" >> "$report_file"
        echo "1. Installing jscpd globally: \`npm install -g jscpd\`" >> "$report_file"
        echo "2. Running with global installation: \`jscpd . --config .jscpd.json --reporters console --verbose\`" >> "$report_file"
        echo "" >> "$report_file"
        echo "Alternatively, you can examine the code manually in the following files that commonly have duplication issues:" >> "$report_file"
        echo "" >> "$report_file"
        
        # Find potential files with duplication by looking for similar file sizes and patterns
        echo "#### Potential Files with Duplication" >> "$report_file"
        echo "" >> "$report_file"
        echo "Files with similar sizes and patterns that might contain duplicated code:" >> "$report_file"
        echo "" >> "$report_file"
        
        # Find terraform files with similar sizes
        echo '```' >> "$report_file"
        find "$ABSOLUTE_PATH" -name "*.tf" -type f -not -path "*/\.*" | xargs wc -l | sort -nr | head -20 >> "$report_file"
        echo '```' >> "$report_file"
        echo "" >> "$report_file"
        
        # Add specific recommendations for EC2 instance module based on memories
        echo "#### Specific Recommendations" >> "$report_file"
        echo "" >> "$report_file"
        echo "Based on recent changes to the EC2 instance module related to CloudWatch alarms and instance state checks, " >> "$report_file"
        echo "there might be duplicated code in the following areas:" >> "$report_file"
        echo "" >> "$report_file"
        echo "1. CloudWatch alarm resource definitions with similar conditional logic" >> "$report_file"
        echo "2. Instance state check logic that may be duplicated across multiple files" >> "$report_file"
        echo "3. Recovery action configuration logic that appears in multiple places" >> "$report_file"
        echo "" >> "$report_file"
        echo "Consider refactoring these patterns into reusable local variables or moved to a centralized module." >> "$report_file"
        
        # Try to identify specific duplicate files by examining the log
        echo "#### Potential Duplicate Files" >> "$report_file"
        echo "" >> "$report_file"
        
        # Look for EC2 instance module files that might have duplicated CloudWatch alarm code
        echo "EC2 instance module files with potential CloudWatch alarm duplication:" >> "$report_file"
        echo "" >> "$report_file"
        echo '```' >> "$report_file"
        find "$ABSOLUTE_PATH" -path "*/ec2*" -name "*.tf" | xargs grep -l "cloudwatch_metric_alarm" | sort >> "$report_file" 2>/dev/null || echo "No matches found" >> "$report_file"
        echo '```' >> "$report_file"
        echo "" >> "$report_file"
        
        echo -e "${RED}✗ Duplicate Code Detection failed - Check report at: ${report_file#$ABSOLUTE_PATH/}${NC}"
        return 1
    else
        echo "## ✅ No Issues Found" >> "$report_file"
        echo "" >> "$report_file"
        echo "No code duplication detected above the threshold!" >> "$report_file"
        
        echo -e "${GREEN}✓ Duplicate Code Detection passed${NC}"
        return 0
    fi
}

# Function to run specific linter
run_linter() {
    local linter=$1
    local title=$2
    local validate_vars=$3
    local report_name=$4
    local report_subdir=$5
    
    echo -e "\n${YELLOW}Running $title...${NC}"
    
    # Create log and report files in appropriate subdirectory
    local log_file="$REPORTS_DIR/$report_subdir/${report_name}.log"
    local report_file="$REPORTS_DIR/$report_subdir/${report_name}.md"
    
    # Build validate flags - disable all first, then enable specific ones
    local validate_flags="-e VALIDATE_ALL_CODEBASE=false"
    IFS=',' read -ra VARS <<< "$validate_vars"
    for var in "${VARS[@]}"; do
        validate_flags="$validate_flags -e VALIDATE_$var=true"
    done
    
    # Run Super-Linter with only the specified linter enabled
    docker run --rm --name "super-linter-$linter-$(date +%s)" \
                   -e RUN_LOCAL=true \
                   $validate_flags \
                   -e MULTI_STATUS=true \
                   -e DEFAULT_BRANCH=main \
                   -e OUTPUT_FORMAT=tap \
                   -e OUTPUT_DETAILS=detailed \
                   -e FILTER_REGEX_EXCLUDE=".*vendor/.*|.*node_modules/.*|.*\.terraform/.*|.*package/.*|.*\.mypy_cache/.*" \
                   -e GIT_DISCOVERY_ACROSS_FILESYSTEM=1 \
                   -e GIT_WORK_TREE=/tmp/lint \
                   -e GIT_DIR=/tmp/lint/.git \
                   -v "$ABSOLUTE_PATH:/tmp/lint" \
                   github/super-linter:v5 2>&1 | tee "$log_file"
                   
    local exit_code=${PIPESTATUS[0]}
    
    # Create formatted report
    create_formatted_report "$log_file" "$report_file" "$title"
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ $title passed${NC}"
        return 0
    else
        echo -e "${RED}✗ $title failed - Check report at: ${report_file#$ABSOLUTE_PATH/}${NC}"
        return 1
    fi
}

# Function to run all linters
run_all_linters() {
    echo -e "\n${YELLOW}Running all linters...${NC}"
    
    # Create main log file
    local log_file="$REPORTS_DIR/all-linters.log"
    local summary_file="$REPORTS_DIR/lint-summary.md"
    
    # Run Super-Linter with all default linters enabled
    docker run --rm --name "super-linter-all-$(date +%s)" \
                   -e RUN_LOCAL=true \
                   -e VALIDATE_MARKDOWN=false \
                   -e VALIDATE_NATURAL_LANGUAGE=false \
                   -e VALIDATE_TERRAFORM_TERRASCAN=false \
                   -e MULTI_STATUS=true \
                   -e DEFAULT_BRANCH=main \
                   -e OUTPUT_FORMAT=tap \
                   -e OUTPUT_DETAILS=detailed \
                   -e CREATE_LOG_FILE=true \
                   -e LOG_LEVEL=INFO \
                   -e FILTER_REGEX_EXCLUDE=".*vendor/.*|.*node_modules/.*|.*\.terraform/.*|.*package/.*|.*\.mypy_cache/.*" \
                   -e VALIDATE_ALL_CODEBASE=false \
                   -e GIT_DISCOVERY_ACROSS_FILESYSTEM=1 \
                   -e GIT_WORK_TREE=/tmp/lint \
                   -e GIT_DIR=/tmp/lint/.git \
                   -v "$ABSOLUTE_PATH:/tmp/lint" \
                   github/super-linter:v5 2>&1 | tee "$log_file"
                   
    local exit_code=${PIPESTATUS[0]}
    
    # Parse log and create individual reports
    echo -e "\n${BLUE}📊 Generating individual linter reports...${NC}"
    
    # Extract Python linting results
    if grep -q "PYTHON" "$log_file"; then
        # Create a clean Python log - extract errors with context
        > "$REPORTS_DIR/python/python-lint.log"  # Clear the file first
        
        # Extract flake8/mypy/pylint errors (format: file.py:line:col: message)
        grep -E "\.py:[0-9]+:[0-9]*:" "$log_file" >> "$REPORTS_DIR/python/python-lint.log" 2>/dev/null || true
        
        # Extract black errors with file context
        grep -B5 -A2 "Found errors in \[black\]" "$log_file" | grep -E "(File:\[|Found errors in \[black\]|Error code:)" >> "$REPORTS_DIR/python/python-lint.log" 2>/dev/null || true
        
        create_formatted_report "$REPORTS_DIR/python/python-lint.log" "$REPORTS_DIR/python/python-lint.md" "Python"
    fi
    
    # Extract Terraform linting results
    if grep -q "TERRAFORM" "$log_file"; then
        grep -E "(\.tf:|TERRAFORM|tflint)" "$log_file" > "$REPORTS_DIR/terraform/terraform-lint.log" 2>/dev/null || true
        create_formatted_report "$REPORTS_DIR/terraform/terraform-lint.log" "$REPORTS_DIR/terraform/terraform-lint.md" "Terraform"
    fi
    
    # Extract Dockerfile linting results
    if grep -q "DOCKERFILE" "$log_file"; then
        grep -E "(Dockerfile|DOCKERFILE|hadolint)" "$log_file" > "$REPORTS_DIR/docker/dockerfile-lint.log" 2>/dev/null || true
        create_formatted_report "$REPORTS_DIR/docker/dockerfile-lint.log" "$REPORTS_DIR/docker/dockerfile-lint.md" "Dockerfile"
    fi
    
    # Extract secret scanning results
    if grep -q "GITLEAKS" "$log_file"; then
        grep -E "(GITLEAKS|secret|credential|key)" "$log_file" > "$REPORTS_DIR/secrets/gitleaks.log" 2>/dev/null || true
        create_formatted_report "$REPORTS_DIR/secrets/gitleaks.log" "$REPORTS_DIR/secrets/gitleaks.md" "Secret Scanning"
    fi
    
    # Create summary report
    echo "# 📊 Lint Summary Report" > "$summary_file"
    echo "" >> "$summary_file"
    echo "**Generated on:** $(date)" >> "$summary_file"
    echo "**Repository:** $(basename "$ABSOLUTE_PATH")" >> "$summary_file"
    echo "**Branch:** $(cd "$ABSOLUTE_PATH" && git branch --show-current 2>/dev/null || echo "unknown")" >> "$summary_file"
    echo "" >> "$summary_file"
    
    # Overall status
    if [ $exit_code -eq 0 ]; then
        echo "## ✅ Overall Status: **PASSED**" >> "$summary_file"
    else
        echo "## ❌ Overall Status: **FAILED**" >> "$summary_file"
    fi
    echo "" >> "$summary_file"
    
    # Summary table
    echo "## 📋 Linter Summary" >> "$summary_file"
    echo "" >> "$summary_file"
    echo "| Category | Report | Status |" >> "$summary_file"
    echo "|----------|--------|--------|" >> "$summary_file"
    
    # Check each category
    for category in python terraform docker secrets; do
        report_file="$REPORTS_DIR/$category/${category}-lint.md"
        if [ -f "$report_file" ]; then
            if grep -q "No Issues Found" "$report_file"; then
                echo "| ${category^} | [View Report]($category/${category}-lint.md) | ✅ Passed |" >> "$summary_file"
            else
                echo "| ${category^} | [View Report]($category/${category}-lint.md) | ❌ Failed |" >> "$summary_file"
            fi
        fi
    done
    
    echo "" >> "$summary_file"
    echo "## 📁 Report Structure" >> "$summary_file"
    echo "" >> "$summary_file"
    echo "\`\`\`" >> "$summary_file"
    echo "lint_reports/" >> "$summary_file"
    echo "├── lint-summary.md          # This file" >> "$summary_file"
    echo "├── all-linters.log          # Complete log" >> "$summary_file"
    echo "├── python/                  # Python linting results" >> "$summary_file"
    echo "│   ├── python-lint.md" >> "$summary_file"
    echo "│   └── python-lint.log" >> "$summary_file"
    echo "├── terraform/               # Terraform linting results" >> "$summary_file"
    echo "│   ├── terraform-lint.md" >> "$summary_file"
    echo "│   └── terraform-lint.log" >> "$summary_file"
    echo "├── docker/                  # Dockerfile linting results" >> "$summary_file"
    echo "│   ├── dockerfile-lint.md" >> "$summary_file"
    echo "│   └── dockerfile-lint.log" >> "$summary_file"
    echo "├── secrets/                 # Secret scanning results" >> "$summary_file"
    echo "│   ├── gitleaks.md" >> "$summary_file"
    echo "│   └── gitleaks.log" >> "$summary_file"
    echo "└── configs/                 # Lint configuration files" >> "$summary_file"
    echo "\`\`\`" >> "$summary_file"
    
    # Move configuration files if they exist
    echo -e "\n${BLUE}📁 Moving configuration files to lint_reports/configs...${NC}"
    for config in .flake8 .gitleaks.toml .jscpd.json .pre-commit-config.yaml; do
        if [ -f "$ABSOLUTE_PATH/$config" ]; then
            cp "$ABSOLUTE_PATH/$config" "$REPORTS_DIR/configs/" 2>/dev/null || true
            echo -e "  Copied $config"
        fi
    done
    
    # Move any existing gitleaks report
    if [ -f "$ABSOLUTE_PATH/gitleaks-report.json" ]; then
        mv "$ABSOLUTE_PATH/gitleaks-report.json" "$REPORTS_DIR/secrets/" 2>/dev/null || true
        echo -e "  Moved gitleaks-report.json"
    fi
    
    if [ $exit_code -eq 0 ]; then
        echo -e "\n${GREEN}✅ All linting passed!${NC}"
    else
        echo -e "\n${RED}❌ Some linting checks failed${NC}"
    fi
    
    echo -e "${BLUE}📄 Summary report: ${summary_file#$ABSOLUTE_PATH/}${NC}"
    echo -e "${BLUE}📁 All reports available in: ${REPORTS_DIR#$ABSOLUTE_PATH/}${NC}"
    
    return $exit_code
}

# Process command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --python|--gitleaks|--jscpd|--terraform|--dockerfile|--help)
            LINTER_OPTION="$1"
            ;;
        --linter=*)
            LINTER_OPTION="--${1#*=}"
            ;;
        /*|./*)
            # This is a directory path
            TARGET_DIR="$1"
            # Update absolute path after setting target directory
            ABSOLUTE_PATH=$(cd "$TARGET_DIR" && pwd || echo "$ABSOLUTE_PATH")
            ;;
        *)
            # Unknown option
            if [[ "$1" != "-"* ]]; then
                # If it doesn't start with a dash, assume it's a directory
                TARGET_DIR="$1"
                # Update absolute path after setting target directory
                ABSOLUTE_PATH=$(cd "$TARGET_DIR" && pwd || echo "$ABSOLUTE_PATH")
            fi
            ;;
    esac
    shift
done

# Process linter option
case "$LINTER_OPTION" in
    --python)
        run_linter "python" "Python Linting" "PYTHON_BLACK,PYTHON_FLAKE8,PYTHON_ISORT,PYTHON_MYPY,PYTHON_PYLINT" "python-lint" "python"
        ;;
    --gitleaks)
        run_linter "gitleaks" "Secret Scanning" "GITLEAKS" "gitleaks" "secrets"
        ;;
    --jscpd)
        run_jscpd_linter
        ;;
    --terraform)
        run_linter "terraform" "Terraform Linting" "TERRAFORM,TERRAFORM_TFLINT" "terraform-lint" "terraform"
        ;;
    --dockerfile)
        run_linter "dockerfile" "Dockerfile Linting" "DOCKERFILE_HADOLINT" "dockerfile-lint" "docker"
        ;;
        --help)
            echo -e "Usage: $0 [directory] [option]"
            echo -e "Options:"
            echo -e "  --python     Run Python linters only"
            echo -e "  --gitleaks   Run secret scanning only"
            echo -e "  --jscpd      Run duplicate code detection only"
            echo -e "  --terraform  Run Terraform linters only"
            echo -e "  --dockerfile Run Dockerfile linter only"
            echo -e "  --help       Show this help message"
            echo -e "\nIf no option is provided, all linters will be run."
            echo -e "\nReports will be saved to: ./lint_reports/"
            echo -e "  ├── lint-summary.md      # Overall summary"
            echo -e "  ├── python/              # Python linting results"
            echo -e "  ├── terraform/           # Terraform linting results"
            echo -e "  ├── docker/              # Dockerfile linting results"
            echo -e "  ├── secrets/             # Secret scanning results"
            echo -e "  └── configs/             # Lint configuration files"
            exit 0
            ;;
        "")
            # No linter option specified, run all linters
            run_all_linters
            ;;
        *)
            echo -e "${RED}Unknown option: $LINTER_OPTION${NC}"
            echo -e "Run '$0 --help' for usage information."
            exit 1
            ;;
esac