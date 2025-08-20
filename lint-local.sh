#!/bin/bash

# Local linting script for terraform-modules
set -e

# Ensure reports directory exists
mkdir -p reports

echo "Running local linters..."

# Function to run TFLint and generate report
run_tflint() {
    echo "Running TFLint..."
    
    # Initialize plugins (requires network access on first run)
    if command -v tflint >/dev/null 2>&1; then
        tflint --init >/dev/null 2>&1 || true
    else
        echo "tflint not found. Install with: brew install tflint" >&2
        return 1
    fi

    # Run TFLint and capture output
    if tflint --recursive --format=compact > /tmp/tflint_output.txt 2>&1; then
        tflint_exit_code=0
    else
        tflint_exit_code=$?
    fi
    
    # Generate markdown report
    cat > reports/tflint/all-modules/terraform-tflint-report.md << 'EOF'
# TFLint Report

## Summary
EOF
    
    if [ $tflint_exit_code -eq 0 ]; then
        {
            echo "✅ **Status**: PASSED - No TFLint issues found"
            echo ""
            echo "All Terraform files passed TFLint validation."
        } >> reports/tflint/all-modules/terraform-tflint-report.md
    else
        # Count issues
        issue_count=$(grep -c "issue(s) found:" /tmp/tflint_output.txt || echo "0")
        if [ "$issue_count" -gt 0 ]; then
            actual_count=$(grep "issue(s) found:" /tmp/tflint_output.txt | sed 's/ issue(s) found://')
        else
            actual_count=$(wc -l < /tmp/tflint_output.txt | tr -d ' ')
        fi
        
        {
            echo "❌ **Status**: FAILED - $actual_count TFLint issues found"
            echo ""
            echo "## Issues Found"
            echo ""
        } >> reports/tflint/all-modules/terraform-tflint-report.md
        
        # Process each line and format as markdown
        while IFS= read -r line; do
            if [[ "$line" =~ ^[0-9]+\ issue\(s\)\ found: ]]; then
                continue  # Skip the summary line
            elif [[ "$line" =~ ^(.+):([0-9]+):([0-9]+):\ (Warning|Error)\ -\ (.+)\ \((.+)\)$ ]]; then
                file="${BASH_REMATCH[1]}"
                line_num="${BASH_REMATCH[2]}"
                col_num="${BASH_REMATCH[3]}"
                severity="${BASH_REMATCH[4]}"
                message="${BASH_REMATCH[5]}"
                rule="${BASH_REMATCH[6]}"
                
                {
                    echo "### $severity: $message"
                    echo ""
                    echo "- **File**: \`$file\`"
                    echo "- **Line**: $line_num:$col_num"
                    echo "- **Rule**: \`$rule\`"
                    echo ""
                } >> reports/tflint/all-modules/terraform-tflint-report.md
            elif [[ -n "$line" ]]; then
                {
                    echo "\`\`\`"
                    echo "$line"
                    echo "\`\`\`"
                    echo ""
                } >> reports/tflint/all-modules/terraform-tflint-report.md
            fi
        done < /tmp/tflint_output.txt
    fi
    
    echo "TFLint report generated: reports/tflint/all-modules/terraform-tflint-report.md"

    # Generate deprecations-only markdown report
    {
        echo "# TFLint Deprecations Report"
        echo ""
        echo "## Summary"
    } > reports/tflint/deprecations/terraform-tflint-deprecations.md

    dep_count=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^(.+):([0-9]+):([0-9]+):\ (Warning|Error)\ -\ (.+)\ \((.+)\)$ ]]; then
            file="${BASH_REMATCH[1]}"; line_num="${BASH_REMATCH[2]}"; col_num="${BASH_REMATCH[3]}"
            severity="${BASH_REMATCH[4]}"; message="${BASH_REMATCH[5]}"; rule="${BASH_REMATCH[6]}"
            # Consider an issue a deprecation if rule id or message mentions 'deprecated'
            if [[ "$rule" =~ [Dd]eprecated || "$message" =~ [Dd]eprecated ]]; then
                dep_count=$((dep_count+1))
                {
                    echo "### $severity: $message"
                    echo ""
                    echo "- **File**: \`$file\`"
                    echo "- **Line**: $line_num:$col_num"
                    echo "- **Rule**: \`$rule\`"
                    echo ""
                } >> reports/tflint/deprecations/terraform-tflint-deprecations.md
            fi
        fi
    done < /tmp/tflint_output.txt

    if [ "$dep_count" -gt 0 ]; then
        sed -i '' "2a\\
**Status**: ❌ $dep_count deprecated syntax issue(s) found\\
" reports/tflint/deprecations/terraform-tflint-deprecations.md 2>/dev/null || true
    else
        echo "✅ **Status**: PASSED - No deprecated syntax found" >> reports/tflint/deprecations/terraform-tflint-deprecations.md
    fi
    echo "TFLint deprecations report generated: reports/tflint/deprecations/terraform-tflint-deprecations.md"
    return $tflint_exit_code
}

# Function to run TFLint only for modules/aws and extract deprecations
run_tflint_aws_deprecations() {
    echo "Running TFLint (modules/aws only)..."
    
    # Initialize plugins
    if command -v tflint >/dev/null 2>&1; then
        tflint --init >/dev/null 2>&1 || true
    else
        echo "tflint not found. Install with: brew install tflint" >&2
        return 1
    fi

    # Run TFLint scoped to modules/aws
    if tflint --recursive --format=compact modules/aws > /tmp/tflint_aws_output.txt 2>&1; then
        tflint_exit_code=0
    else
        tflint_exit_code=$?
    fi

    # Deprecations-only markdown report for modules/aws
    {
        echo "# TFLint Deprecations (modules/aws)"
        echo ""
        echo "## Summary"
    } > reports/tflint/aws-modules/aws-tflint-deprecations.md

    dep_count=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^(.+):([0-9]+):([0-9]+):\ (Warning|Error)\ -\ (.+)\ \((.+)\)$ ]]; then
            file="${BASH_REMATCH[1]}"; line_num="${BASH_REMATCH[2]}"; col_num="${BASH_REMATCH[3]}"
            severity="${BASH_REMATCH[4]}"; message="${BASH_REMATCH[5]}"; rule="${BASH_REMATCH[6]}"
            # Consider an issue a deprecation if rule id or message mentions 'deprecated'
            if [[ "$rule" =~ [Dd]eprecated || "$message" =~ [Dd]eprecated ]]; then
                dep_count=$((dep_count+1))
                {
                    echo "### $severity: $message"
                    echo ""
                    echo "- **File**: \`$file\`"
                    echo "- **Line**: $line_num:$col_num"
                    echo "- **Rule**: \`$rule\`"
                    echo ""
                } >> reports/tflint/aws-modules/aws-tflint-deprecations.md
            fi
        fi
    done < /tmp/tflint_aws_output.txt

    if [ "$dep_count" -gt 0 ]; then
        sed -i '' "2a\\
**Status**: ❌ $dep_count deprecated syntax issue(s) found in modules/aws\\
" reports/tflint/aws-modules/aws-tflint-deprecations.md 2>/dev/null || true
    else
        echo "✅ **Status**: PASSED - No TFLint deprecation issues found in modules/aws" >> reports/tflint/aws-modules/aws-tflint-deprecations.md
    fi
    
    echo "TFLint deprecations report generated: reports/tflint/aws-modules/aws-tflint-deprecations.md"
}

# Function to run terraform validate with -upgrade on AWS modules only
run_terraform_validate_aws_deprecations() {
    echo "Running terraform validate (with -upgrade) under modules/aws..."
    
    # Create the deprecations report directory
    mkdir -p reports/terraform-validate/deprecations
    
    # Initialize the report file
    cat > reports/terraform-validate/deprecations/aws-terraform-validate-deprecations.md << 'EOF'
# Terraform Validate Deprecations (modules/aws)

## Summary
EOF

    # Find all directories under modules/aws that contain .tf files
    find modules/aws -name "*.tf" -type f | sed 's|/[^/]*\.tf$||' | sort -u | while read -r module_dir; do
        if [ -d "$module_dir" ]; then
            echo "Validating $module_dir..."
            
            # Change to the module directory
            cd "$module_dir" || continue
            
            # Run terraform init -upgrade and capture output
            init_output=$(terraform init -backend=false -upgrade 2>&1)
            init_exit_code=$?
            
            if [ $init_exit_code -eq 0 ]; then
                # Run terraform validate and capture output
                validate_output=$(terraform validate 2>&1)
                # validate_exit_code=$? # Unused variable removed
                
                # Check if there are warnings (even if exit code is 0)
                if echo "$validate_output" | grep -q "Warning:"; then
                    module_name=$(basename "$module_dir")
                    {
                        echo "### ⚠️ Warnings in \`modules/aws/$module_name\`"
                        echo ""
                        echo "\`\`\`"
                        echo "$validate_output"
                        echo "\`\`\`"
                        echo ""
                    } >> ../../../reports/terraform-validate/deprecations/aws-terraform-validate-deprecations.md
                fi
            else
                module_name=$(basename "$module_dir")
                {
                    echo "### ❌ Init Failed in \`modules/aws/$module_name\`"
                    echo ""
                    echo "\`\`\`"
                    echo "$init_output"
                    echo "\`\`\`"
                    echo ""
                } >> ../../../reports/terraform-validate/deprecations/aws-terraform-validate-deprecations.md
            fi
            
            # Return to the root directory
            cd - > /dev/null || exit 1
        fi
    done
    
    echo "Terraform validate deprecations report generated: reports/terraform-validate/deprecations/aws-terraform-validate-deprecations.md"
}

# Function to run terraform validate across all Terraform directories
run_terraform_validate() {
    echo "Running terraform validate..."

    if ! command -v terraform >/dev/null 2>&1; then
        echo "terraform not found. Install with: brew tap hashicorp/tap && brew install hashicorp/tap/terraform" >&2
        return 1
    fi

    cat > reports/terraform-validate/all-modules/terraform-validate-report.md << 'EOF'
# Terraform Validate Report

## Summary
EOF

    # Find unique directories containing .tf files (exclude .terraform and hidden dirs)
    tf_dirs_file=$(mktemp)
    find . -type f -name '*.tf' \
        -not -path '*/.terraform/*' -not -path './.*/*' -print0 \
        | xargs -0 -n1 dirname | sort -u > "$tf_dirs_file"

    total=$(wc -l < "$tf_dirs_file" | tr -d ' ')
    failures=0

    while IFS= read -r dir; do
        # Init without backend to avoid touching remote state; ignore errors to continue scanning
        terraform -chdir="$dir" init -backend=false -input=false >/dev/null 2>&1 || true
        if out=$(terraform -chdir="$dir" validate 2>&1); then
            {
                echo "### ✅ PASS: \`$dir\`"
                echo ""
            } >> reports/terraform-validate/all-modules/terraform-validate-report.md
        else
            failures=$((failures+1))
            {
                echo "### ❌ FAIL: \`$dir\`"
                echo ""
                echo "\`\`\`"
                echo "$out"
                echo "\`\`\`"
                echo ""
            } >> reports/terraform-validate/all-modules/terraform-validate-report.md
        fi
    done < "$tf_dirs_file"

    rm -f "$tf_dirs_file"

    if [ "$failures" -gt 0 ]; then
        sed -i '' "2a\\
**Status**: ❌ $failures of $total directories failed validation\\
" reports/terraform-validate/all-modules/terraform-validate-report.md 2>/dev/null || true
    else
        echo "✅ **Status**: PASSED - All $total directories validated successfully" >> reports/terraform-validate/all-modules/terraform-validate-report.md
    fi

    echo "Terraform validate report generated: reports/terraform-validate/all-modules/terraform-validate-report.md"
}

# Function to run other linters
run_shellcheck() {
    echo "Running ShellCheck..."
    
    if command -v shellcheck >/dev/null 2>&1; then
        find . -name "*.sh" -not -path "./.*" -print0 | xargs -0 shellcheck -f gcc > /tmp/shellcheck_output.txt 2>&1 || true
        
        cat > reports/shellcheck/bash-shellcheck-report.md << 'EOF'
# ShellCheck Report

## Summary
EOF
        
        if [ -s /tmp/shellcheck_output.txt ]; then
            issue_count=$(wc -l < /tmp/shellcheck_output.txt | tr -d ' ')
            {
                echo "❌ **Status**: FAILED - $issue_count ShellCheck issues found"
                echo ""
                echo "## Issues Found"
                echo ""
                echo "\`\`\`"
                cat /tmp/shellcheck_output.txt
                echo "\`\`\`"
            } >> reports/shellcheck/bash-shellcheck-report.md
        else
            echo "✅ **Status**: PASSED - No ShellCheck issues found" >> reports/shellcheck/bash-shellcheck-report.md
        fi
        
        echo "ShellCheck report generated: reports/shellcheck/bash-shellcheck-report.md"
    else
        echo "ShellCheck not found, skipping..."
    fi
}

# Function to run TFLint on ThinkStack modules only for deprecations
run_tflint_thinkstack_deprecations() {
    echo "Running TFLint (modules/thinkstack only)..."
    
    # Create the deprecations report directory
    mkdir -p reports/tflint/thinkstack-modules
    
    # Run TFLint on modules/thinkstack directory only
    if tflint --chdir=modules/thinkstack --format=compact > /tmp/tflint_thinkstack_output.txt 2>&1; then
        tflint_exit_code=0
    else
        tflint_exit_code=$?
    fi
    
    # Generate the report
    cat > reports/tflint/thinkstack-modules/thinkstack-tflint-deprecations.md << 'EOF'
# TFLint Deprecations (modules/thinkstack)

## Summary
EOF

    if [ $tflint_exit_code -eq 0 ]; then
        echo "✅ **Status**: PASSED - No TFLint deprecation issues found in modules/thinkstack" >> reports/tflint/thinkstack-modules/thinkstack-tflint-deprecations.md
    else
        {
            echo "❌ **Status**: FAILED - TFLint deprecation issues found in modules/thinkstack"
            echo ""
            echo "## Issues Found"
            echo ""
            echo "\`\`\`"
            cat /tmp/tflint_thinkstack_output.txt
            echo "\`\`\`"
        } >> reports/tflint/thinkstack-modules/thinkstack-tflint-deprecations.md
    fi
    
    echo "TFLint deprecations report generated: reports/tflint/thinkstack-modules/thinkstack-tflint-deprecations.md"
}

# Function to run terraform validate with -upgrade on ThinkStack modules only
run_terraform_validate_thinkstack_deprecations() {
    echo "Running terraform validate (with -upgrade) under modules/thinkstack..."
    
    # Create the deprecations report directory
    mkdir -p reports/terraform-validate/deprecations
    
    # Initialize the report file
    cat > reports/terraform-validate/deprecations/thinkstack-terraform-validate-deprecations.md << 'EOF'
# Terraform Validate Deprecations (modules/thinkstack)

## Summary
EOF

    # Find all directories under modules/thinkstack that contain .tf files
    find modules/thinkstack -name "*.tf" -type f | sed 's|/[^/]*\.tf$||' | sort -u | while read -r module_dir; do
        if [ -d "$module_dir" ]; then
            echo "Validating $module_dir..."
            
            # Change to the module directory
            cd "$module_dir" || continue
            
            # Run terraform init -upgrade and capture output
            init_output=$(terraform init -backend=false -upgrade 2>&1)
            init_exit_code=$?
            
            if [ $init_exit_code -eq 0 ]; then
                # Run terraform validate and capture output
                validate_output=$(terraform validate 2>&1)
                # validate_exit_code=$? # Unused variable removed
                
                # Check if there are warnings (even if exit code is 0)
                if echo "$validate_output" | grep -q "Warning:"; then
                    module_name=$(basename "$module_dir")
                    {
                        echo "### ⚠️ Warnings in \`modules/thinkstack/$module_name\`"
                        echo ""
                        echo "\`\`\`"
                        echo "$validate_output"
                        echo "\`\`\`"
                        echo ""
                    } >> ../../../reports/terraform-validate/deprecations/thinkstack-terraform-validate-deprecations.md
                fi
            else
                module_name=$(basename "$module_dir")
                {
                    echo "### ❌ Init Failed in \`modules/thinkstack/$module_name\`"
                    echo ""
                    echo "\`\`\`"
                    echo "$init_output"
                    echo "\`\`\`"
                    echo ""
                } >> ../../../reports/terraform-validate/deprecations/thinkstack-terraform-validate-deprecations.md
            fi
            
            # Return to the root directory
            cd - > /dev/null || exit 1
        fi
    done
    
    echo "Terraform validate deprecations report generated: reports/terraform-validate/deprecations/thinkstack-terraform-validate-deprecations.md"
}

# Function to run Python Black
run_black() {
    echo "Running Python Black..."
    
    if command -v black >/dev/null 2>&1; then
        if black --check --diff . > /tmp/black_output.txt 2>&1; then
            black_exit_code=0
        else
            black_exit_code=$?
        fi
        
        cat > reports/python-black/python-black-report.md << 'EOF'
# Python Black Report

## Summary
EOF
        
        if [ $black_exit_code -eq 0 ]; then
            echo "✅ **Status**: PASSED - No Python Black formatting issues found" >> reports/python-black/python-black-report.md
        else
            {
                echo "❌ **Status**: FAILED - Python Black formatting issues found"
                echo ""
                echo "## Issues Found"
                echo ""
                echo "\`\`\`diff"
                cat /tmp/black_output.txt
                echo "\`\`\`"
            } >> reports/python-black/python-black-report.md
        fi
        
        echo "Python Black report generated: reports/python-black/python-black-report.md"
    else
        echo "Python Black not found, skipping..."
    fi
}

# Main execution
case "${1:-all}" in
    "tflint"|"terraform-tflint")
        run_tflint
        ;;
    "aws-deprecations"|"deprecations-aws")
        run_tflint_aws_deprecations || true
        run_terraform_validate_aws_deprecations || true
        ;;
    "thinkstack-deprecations"|"deprecations-thinkstack")
        run_tflint_thinkstack_deprecations || true
        run_terraform_validate_thinkstack_deprecations || true
        ;;
    "shellcheck"|"bash")
        run_shellcheck
        ;;
    "black"|"python-black")
        run_black
        ;;
    "all")
        echo "Running all linters..."
        tflint_result=0
        run_tflint || tflint_result=$?
        run_terraform_validate || true
        run_shellcheck
        run_black
        
        if [ $tflint_result -ne 0 ]; then
            echo "❌ Some linters failed. Check the reports in the reports/ directory."
            exit 1
        else
            echo "✅ All linters passed!"
        fi
        ;;
    *)
        echo "Usage: $0 [tflint|aws-deprecations|thinkstack-deprecations|shellcheck|black|all]"
        echo "  tflint               - Run TFLint only"
        echo "  aws-deprecations     - Scan only modules/aws for deprecated syntax (TFLint + terraform validate)"
        echo "  thinkstack-deprecations - Scan only modules/thinkstack for deprecated syntax (TFLint + terraform validate)"
        echo "  shellcheck           - Run ShellCheck only"  
        echo "  black                - Run Python Black only"
        echo "  all                  - Run all linters (default)"
        exit 1
        ;;
esac
