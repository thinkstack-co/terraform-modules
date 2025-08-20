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

# Define the Super-Linter image to use
SUPER_LINTER_IMAGE="ghcr.io/super-linter/super-linter:latest"

# Ensure reports directory exists
mkdir -p reports

# Create a temporary event file for GitHub Actions compatibility in the project directory
# so it's accessible inside the Docker container
GITHUB_EVENT_FILE="$(pwd)/.github_event.json"
GITHUB_EVENT_PATH_IN_CONTAINER="/tmp/lint/.github_event.json"
echo '{"repository": {"default_branch": "main"}}' > "$GITHUB_EVENT_FILE"

# Get current git commit SHA
GIT_SHA=$(git rev-parse HEAD 2>/dev/null || echo "HEAD")

# Create lint_reports directory structure
REPORTS_DIR="$ABSOLUTE_PATH/lint_reports"
mkdir -p "$REPORTS_DIR"/{terraform,python,docker,secrets,duplicates,configs}

# Clean up old reports
find "$REPORTS_DIR" \( -name "*.log" -o -name "*.md" -o -name "*.json" \) -print0 | xargs -0 rm -f 2>/dev/null || true

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

# Function to extract Python Black linter errors
extract_black_errors() {
    local log_file=$1
    local report_file=$2
    local error_count=0
    
    # Find all instances of Black errors
    local black_errors
    black_errors=$(grep -n "Found errors in \[black\]" "$log_file" | cut -d: -f1)
    
    if [ -n "$black_errors" ]; then
        echo "## 🔍 Issues Found" >> "$report_file"
        echo "" >> "$report_file"
        
        for line_num in $black_errors; do
            # Extract the file path from the previous line
            local file_path
            file_path=$(sed -n "$((line_num-2))p" "$log_file" | grep -o "File:\[.*\]" | sed 's/File:\[\(.*\)\]/\1/')
            file_path="${file_path#/tmp/lint/}"
            
            # Extract the diff output
            local start_diff=$((line_num+2))
            local diff_output
            diff_output=$(sed -n "$start_diff,/^------$/p" "$log_file" | sed '/^------$/d')
            
            if [ -n "$file_path" ]; then
                echo "### 📄 \`$file_path\`" >> "$report_file"
                echo "" >> "$report_file"
                echo "- **Formatting Error:** File needs black formatting" >> "$report_file"
                echo "" >> "$report_file"
                echo "\`\`\`diff" >> "$report_file"
                echo "$diff_output" >> "$report_file"
                echo "\`\`\`" >> "$report_file"
                echo "" >> "$report_file"
                ((error_count++))
            fi
        done
    fi
    
    return $error_count
}

# Function to create a report header
create_report_header() {
    local linter_name=$1
    local report_file=$2
    
    echo "# $linter_name Lint Report" > "$report_file"
    echo "" >> "$report_file"
    echo "Generated on: $(date)" >> "$report_file"
    echo "Repository: terraform-modules" >> "$report_file"
    echo "" >> "$report_file"
}

# Function to extract TFLint errors
extract_tflint_errors() {
    local log_file=$1
    local report_file=$2
    local error_count=0
    local warning_count=0
    
    # Create report header
    create_report_header "Terraform TFLint" "$report_file"
    
    if [ -f "$log_file" ]; then
        echo "## 🔍 TFLint Results" >> "$report_file"
        echo "" >> "$report_file"
        
        # Process the file line by line to organize errors by file
        local current_file=""
        # local has_errors=false # Unused variable
        
        # Extract TFLint errors from the log file
        local errors
        errors=$(grep -E "\[ERROR\]|\[WARNING\]|Error:|Warning:" "$log_file" | grep -v "Terraform TFLint" | sort -u)
        
        # If no errors found with the above pattern, try another common TFLint output pattern
        if [ -z "$errors" ]; then
            errors=$(grep -E "^[^:]+:[0-9]+:[0-9]+: \[\w+\]" "$log_file" | sort -u)
        fi
        
        if [ -n "$errors" ]; then
            echo "### TFLint Issues" >> "$report_file"
            echo "" >> "$report_file"
            echo '```' >> "$report_file"
            echo "$errors" >> "$report_file"
            echo '```' >> "$report_file"
            echo "" >> "$report_file"
            
            # Count errors and warnings
            error_count=$(echo "$errors" | grep -c -E "\[ERROR\]|Error:")
            warning_count=$(echo "$errors" | grep -c -E "\[WARNING\]|Warning:")
            
            # If the above counting method returned 0, try another method
            if [ "$error_count" -eq 0 ] && [ "$warning_count" -eq 0 ]; then
                error_count=$(echo "$errors" | wc -l)
            fi
        else
            echo "✅ No TFLint issues found." >> "$report_file"
        fi
    else
        echo "## ⚠️ Warning: TFLint output file not found" >> "$report_file"
        echo "" >> "$report_file"
        echo "Could not find TFLint output file at: $log_file" >> "$report_file"
        echo "Please run with --debug flag for more information." >> "$report_file"
        echo "" >> "$report_file"
    fi
    
    # Add summary section
    echo "## 📊 Summary" >> "$report_file"
    echo "- **Errors:** $error_count" >> "$report_file"
    echo "- **Warnings:** $warning_count" >> "$report_file"
    echo "" >> "$report_file"
    
    # Return non-zero if we found any errors
    if [ "$error_count" -gt 0 ]; then
        return 1
    else
        return 0
    fi
}

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
    
    # Special handling for Python Black linter
    if [[ "$linter_name" == "Python Linting" ]] && grep -q "Found errors in \[black\]" "$log_file"; then
        extract_black_errors "$log_file" "$report_file"
        local black_errors=$?
        error_count=$((error_count + black_errors))
    fi
    
    # Special handling for TFLint
    if [[ "$linter_name" == "Terraform TFLint" ]] && grep -q "TERRAFORM_TFLINT.*error" "$log_file"; then
        extract_tflint_errors "$log_file" "$report_file"
        local tflint_errors=$?
        if [ $tflint_errors -ne 0 ]; then
            error_count=$((error_count + 1))
        fi
        # Return early since we've already created the full report
        return $error_count
    fi
    
    # Create temporary file for parsing
    local temp_file
    temp_file=$(mktemp)
    
    # Extract relevant error lines with improved pattern matching
    # For Python: look for .py: patterns (flake8, mypy errors)
    # For black: look for specific error patterns
    # For tflint: look for specific error patterns
    grep -E "(\.py:[0-9]+:|\.tf:[0-9]+:|ERROR.*\.py|Found errors in \[|would be reformatted|would be left unchanged|WARNING:)" "$log_file" 2>/dev/null | \
    grep -v "ERROR SUMMARY" | \
    grep -v "not a git repository" | \
    grep -v "Validate ENV files" | \
    grep -v "was linted with.*successfully" > "$temp_file" || true
    
    # Also capture black formatting errors which have a different pattern
    grep -A 2 "reformatting .*\.py" "$log_file" 2>/dev/null >> "$temp_file" || true
    
    # Capture black diff output which shows formatting issues
    grep -A 50 "^--- .*\.py" "$log_file" 2>/dev/null | grep -B 50 "^Error code: 1" >> "$temp_file" || true
    
    # Capture tflint warnings and errors
    grep -E "(\[ERROR\]|\[WARN\]).*\.tf" "$log_file" 2>/dev/null >> "$temp_file" || true
    
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
            if [[ "$line" =~ Found\ errors\ in\ \[black\] ]] && [[ -n "$black_error_file" ]]; then
                # We have a black error for the file stored in black_error_file
                continue
            fi
            
            # Check for black reformatting indicator
            if [[ "$line" =~ "reformatting "(.+\.py) ]]; then
                black_error_file="${BASH_REMATCH[1]}"
                black_error_file="${black_error_file#/tmp/lint/}"
                if [[ "$black_error_file" != "$current_file" ]]; then
                    if [[ -n "$current_file" ]]; then
                        echo "" >> "$report_file"
                    fi
                    echo "### 📄 \`$black_error_file\`" >> "$report_file"
                    current_file="$black_error_file"
                fi
                echo "- **Formatting Error:** File needs black formatting" >> "$report_file"
                ((error_count++))
                continue
            fi
            
            # Check for black diff output (--- file.py line indicates start of diff)
            if [[ "$line" =~ ^---\ (.+\.py) ]]; then
                black_error_file="${BASH_REMATCH[1]}"
                black_error_file="${black_error_file#/tmp/lint/}"
                if [[ "$black_error_file" != "$current_file" ]]; then
                    if [[ -n "$current_file" ]]; then
                        echo "" >> "$report_file"
                    fi
                    echo "### 📄 \`$black_error_file\`" >> "$report_file"
                    current_file="$black_error_file"
                fi
                echo "- **Formatting Error:** File needs black formatting (see log for diff)" >> "$report_file"
                ((error_count++))
                continue
            fi
            
            # Check for tflint error indicator
            if [[ "$line" =~ "\[ERROR\]".*\.tf ]] || [[ "$line" =~ "\[WARN\]".*\.tf ]]; then
                # Extract file and message for tflint
                if [[ "$line" =~ \[(ERROR|WARN)\]\ ([^:]+\.tf):(.*) ]]; then
                    local tf_file="${BASH_REMATCH[2]}"
                    tf_file="${tf_file#/tmp/lint/}"
                    local tf_message="${BASH_REMATCH[3]}"
                    local severity="${BASH_REMATCH[1]}"
                    
                    if [[ "$tf_file" != "$current_file" ]]; then
                        if [[ -n "$current_file" ]]; then
                            echo "" >> "$report_file"
                        fi
                        echo "### 📄 \`$tf_file\`" >> "$report_file"
                        current_file="$tf_file"
                    fi
                    
                    echo "- **$severity:** $tf_message" >> "$report_file"
                    if [[ "$severity" == "ERROR" ]]; then
                        ((error_count++))
                    else
                        ((warning_count++))
                    fi
                    continue
                fi
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
    echo "_Full log available at: \`${log_file#"$ABSOLUTE_PATH"/}\`_" >> "$report_file"
}

# Function to run JSCPD linter with enhanced reporting
run_jscpd_linter() {
    echo -e "\n${YELLOW}Running Duplicate Code Detection with detailed output...${NC}"
    
    # Create log and report files
    local log_file="$REPORTS_DIR/duplicates/duplicate-code.log"
    local report_file="$REPORTS_DIR/duplicates/duplicate-code.md"
    # local json_file="$REPORTS_DIR/duplicates/duplicate-code.json" # Unused variable
    
    # Run JSCPD with detailed output
    docker run --rm --name "super-linter-jscpd-$(date +%s)" \
                   -e RUN_LOCAL=true \
                   -e LOG_LEVEL=DEBUG \
                   -e LOG_FILE=super-linter.log \
                   -e CREATE_LOG_FILE=true \
                   -e VALIDATE_JSCPD=true \
                   -e JSCPD_CONFIG_FILE=.jscpd.json \
                   -e JSCPD_CONFIG_THRESHOLD=5 \
                   -e FILTER_REGEX_INCLUDE=".*" \
                   -e FILTER_REGEX_EXCLUDE="(.*\.git/.*|.*node_modules/.*)" \
                   -e LINTER_RULES_PATH=/ \
                   -e DEFAULT_WORKSPACE=/ \
                   -e TAP_REPORTER=true \
                   -e REPORT_OUTPUT_FOLDER=/tmp/lint/lint_reports \
                   -e GITHUB_WORKSPACE=/tmp/lint \
                   -e GITHUB_REPOSITORY=terraform-modules \
                   -e GIT_DISCOVERY_ACROSS_FILESYSTEM=1 \
                   -e GIT_WORK_TREE=/tmp/lint \
                   -e GIT_DIR=/tmp/lint/.git \
                   -v "$ABSOLUTE_PATH:/tmp/lint" \
                   github/super-linter:v5 2>&1 | tee "$log_file"
                   
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
        local dup_percent
        dup_percent=$(grep -o "duplicates ([0-9.]\+%)" "$log_file" | grep -o "[0-9.]\+" || echo "unknown")
        echo "### Duplication Rate: ${dup_percent}%" >> "$report_file"
        echo "" >> "$report_file"
        
        # Extract clone count
        local clone_count
        clone_count=$(grep -o "Found [0-9]\+ clones" "$log_file" | grep -o "[0-9]\+" || echo "unknown")
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
        find "$ABSOLUTE_PATH" -name "*.tf" -type f -not -path "*/\.*" -print0 | xargs -0 wc -l | sort -nr | head -20 >> "$report_file"
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
        find "$ABSOLUTE_PATH" -path "*/ec2*" -name "*.tf" -print0 | xargs -0 grep -l "cloudwatch_metric_alarm" | sort >> "$report_file" 2>/dev/null || echo "No matches found" >> "$report_file"
        echo '```' >> "$report_file"
        echo "" >> "$report_file"
        
        echo -e "${RED}✗ Duplicate Code Detection failed - Check report at: ${report_file#"$ABSOLUTE_PATH"/}${NC}"
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
    local linter_type=$1
    local linter_name=$2
    local report_dir=$3
    local validate_env_var=$4
    local additional_env_vars=$5
    
    echo "Running $linter_name linter..."
    
    # Create report directory if it doesn't exist
    mkdir -p "$report_dir"
    
    # Create a unique report file name
    local report_file="$report_dir/${linter_type}.md"
    
    # Create the report header
    create_report_header "$linter_name" "$report_file"
    
    # Special handling for TFLint to capture its output separately
    if [[ "$linter_name" == "Terraform TFLint" ]]; then
        # Run TFLint and capture its output to a separate file
        docker run --rm \
            -v "$(pwd):/tmp/lint" \
            -e "GITHUB_WORKSPACE=/tmp/lint" \
            -e "GITHUB_EVENT_PATH=$GITHUB_EVENT_PATH_IN_CONTAINER" \
            -e "GITHUB_REPOSITORY=local/repo" \
            -e "GITHUB_REPOSITORY_OWNER=local" \
            -e "GITHUB_SHA=$GIT_SHA" \
            -e "$validate_env_var=true" \
            -e "LOG_LEVEL=DEBUG" \
            -e "LOG_FILE=true" \
            -e "LOG_FILE_PATH=/tmp/lint/super-linter.log" \
            "$additional_env_vars" \
            $SUPER_LINTER_IMAGE 2>&1 | tee /tmp/tflint_output.txt
    else
        # Run the linter normally
        docker run --rm \
            -v "$(pwd):/tmp/lint" \
            -e "GITHUB_WORKSPACE=/tmp/lint" \
            -e "GITHUB_EVENT_PATH=$GITHUB_EVENT_PATH_IN_CONTAINER" \
            -e "GITHUB_REPOSITORY=local/repo" \
            -e "GITHUB_REPOSITORY_OWNER=local" \
            -e "GITHUB_SHA=$GIT_SHA" \
            -e "$validate_env_var=true" \
            -e "LOG_LEVEL=DEBUG" \
            -e "LOG_FILE=true" \
            -e "LOG_FILE_PATH=/tmp/lint/super-linter.log" \
            "$additional_env_vars" \
            $SUPER_LINTER_IMAGE
    fi
    
    # Check if the linter found any issues
    local exit_code=$?
    
    # Special handling for TFLint output
    if [[ "$linter_name" == "Terraform TFLint" ]] && [ -f "/tmp/tflint_output.txt" ]; then
        # Parse TFLint output directly
        extract_tflint_errors "/tmp/tflint_output.txt" "$report_file"
        local report_exit_code=$?
        
        # Clean up the output file
        rm -f "/tmp/tflint_output.txt"
        
        if [ $report_exit_code -ne 0 ] || [ $exit_code -ne 0 ]; then
            echo "✗ $linter_name failed - Check report at: $report_file"
            return 1
        else
            echo "✓ $linter_name passed"
            return 0
        fi
    # For other linters, try to use the Super-Linter log file
    elif [ -f "/tmp/lint/super-linter.log" ]; then
        create_formatted_report "/tmp/lint/super-linter.log" "$report_file" "$linter_name"
        local report_exit_code=$?
        
        # Clean up the log file
        rm -f "/tmp/lint/super-linter.log"
        
        if [ $report_exit_code -ne 0 ] || [ $exit_code -ne 0 ]; then
            echo "✗ $linter_name failed - Check report at: $report_file"
            return 1
        else
            echo "✓ $linter_name passed"
            return 0
        fi
    else
        # If no log file is found, create a basic report
        echo "## ⚠️ Warning: No log file found" >> "$report_file"
        echo "" >> "$report_file"
        echo "The linter was executed, but no log file was found to parse for detailed errors." >> "$report_file"
        
        if [ $exit_code -ne 0 ]; then
            echo "✗ $linter_name failed - Check report at: $report_file"
            return 1
        else
            echo "✓ $linter_name passed"
            return 0
        fi
    fi
}

# Function to run all linters
run_all_linters() {
    echo -e "\n${YELLOW}Running all linters sequentially...${NC}"
    
    local summary_file="$REPORTS_DIR/lint-summary.md"
    local all_linters_log="$REPORTS_DIR/all-linters.log"
    true > "$all_linters_log"  # Initialize empty log file
    
    # Track overall exit code
    local overall_exit_code=0
    
    # Run each linter category sequentially
    echo -e "\n${BLUE}Running Python linters...${NC}"
    if ! run_linter "python" "Python Linting" "PYTHON_BLACK,PYTHON_FLAKE8,PYTHON_ISORT,PYTHON_MYPY,PYTHON_PYLINT" "python-lint" "python"; then
        overall_exit_code=1
    fi
    cat "$REPORTS_DIR/python/python-lint.log" >> "$all_linters_log" 2>/dev/null || true
    
    echo -e "\n${BLUE}Running Terraform linters...${NC}"
    if ! run_linter "terraform" "Terraform Linting" "TERRAFORM,TERRAFORM_TFLINT" "terraform-lint" "terraform"; then
        overall_exit_code=1
    fi
    cat "$REPORTS_DIR/terraform/terraform-lint.log" >> "$all_linters_log" 2>/dev/null || true
    
    echo -e "\n${BLUE}Running Dockerfile linters...${NC}"
    if ! run_linter "dockerfile" "Dockerfile Linting" "DOCKERFILE_HADOLINT" "dockerfile-lint" "docker"; then
        exit_code=1
    fi
    cat "$REPORTS_DIR/docker/dockerfile-lint.log" >> "$all_linters_log" 2>/dev/null || true
    
    # Create summary report
    echo "# 📊 Linting Summary Report" > "$summary_file"
    echo "" >> "$summary_file"
    echo "**Generated on:** $(date)" >> "$summary_file"
    echo "**Repository:** $(basename "$ABSOLUTE_PATH")" >> "$summary_file"
    echo "**Branch:** $(cd "$ABSOLUTE_PATH" && git branch --show-current 2>/dev/null || echo "unknown")" >> "$summary_file"
    echo "" >> "$summary_file"
    
    # Overall status
    if [ "$exit_code" -eq 0 ]; then
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
                category_cap=$(echo "$category" | tr '[:lower:]' '[:upper:]' | sed 's/_.*//')
                echo "| $category_cap | [View Report]($category/${category}-lint.md) | ✅ Passed |" >> "$summary_file"
            else
                category_cap=$(echo "$category" | tr '[:lower:]' '[:upper:]' | sed 's/_.*//')
                echo "| $category_cap | [View Report]($category/${category}-lint.md) | ❌ Failed |" >> "$summary_file"
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
    
    if [ "$exit_code" -eq 0 ]; then
        echo -e "\n${GREEN}✅ All linting passed!${NC}"
    else
        echo -e "\n${RED}❌ Some linting checks failed${NC}"
    fi
    
    echo -e "${BLUE}📄 Summary report: ${summary_file#"$ABSOLUTE_PATH"/}${NC}"
    echo -e "${BLUE}📁 All reports available in: ${REPORTS_DIR#"$ABSOLUTE_PATH"/}${NC}"
    
    return "$exit_code"
}

# Process command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --python|--gitleaks|--jscpd|--terraform|--dockerfile|--terraform-fmt|--terraform-tflint|--bash|--help)
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
        -*)
            # Unknown option that starts with a dash
            echo -e "${RED}Error: Unknown option '$1'${NC}"
            echo -e "Run '$0 --help' for usage information."
            exit 1
            ;;
        *)
            # If it doesn't start with a dash, assume it's a directory
            TARGET_DIR="$1"
            # Update absolute path after setting target directory
            ABSOLUTE_PATH=$(cd "$TARGET_DIR" && pwd || echo "$ABSOLUTE_PATH")
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
    --terraform-fmt)
        run_linter "terraform-fmt" "Terraform Formatting" "TERRAFORM_FMT" "terraform-fmt" "terraform"
        ;;
    --terraform-tflint)
        run_linter "terraform-tflint" "Terraform TFLint" "$REPORTS_DIR/terraform" "VALIDATE_TERRAFORM_TFLINT" ""
        ;;
    --bash)
        run_linter "bash" "Bash Linting" "BASH,BASH_EXEC" "bash-lint" "bash"
        ;;
    --dockerfile)
        run_linter "dockerfile" "Dockerfile Linting" "DOCKERFILE_HADOLINT" "dockerfile-lint" "docker"
        ;;
        --help)
            echo -e "Usage: $0 [directory] [option]"
            echo -e "Options:"
            echo -e "  --python          Run all Python linters (black, flake8, isort, mypy, pylint)"
            echo -e "  --gitleaks        Run secret scanning only"
            echo -e "  --jscpd           Run duplicate code detection only"
            echo -e "  --terraform       Run all Terraform linters (fmt and tflint)"
            echo -e "  --terraform-fmt   Run Terraform formatting check only"
            echo -e "  --terraform-tflint Run Terraform tflint check only"
            echo -e "  --bash            Run Bash linters only"
            echo -e "  --dockerfile      Run Dockerfile linter only"
            echo -e "  --help            Show this help message"
            echo -e "\nIf no option is provided, all linters will be run sequentially."
            echo -e "\nReports will be saved to: ./lint_reports/"
            echo -e "  ├── lint-summary.md      # Overall summary"
            echo -e "  ├── python/              # Python linting results"
            echo -e "  ├── terraform/           # Terraform linting results"
            echo -e "  ├── docker/              # Dockerfile linting results"
            echo -e "  ├── bash/                # Bash linting results"
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