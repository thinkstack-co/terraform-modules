#!/bin/bash

# Local linting script for terraform-modules
set -e

# Ensure reports directory exists
mkdir -p reports

echo "Running local linters..."

# Function to run TFLint and generate report
run_tflint() {
    echo "Running TFLint..."
    
    # Run TFLint and capture output
    if tflint --recursive --format=compact > /tmp/tflint_output.txt 2>&1; then
        tflint_exit_code=0
    else
        tflint_exit_code=$?
    fi
    
    # Generate markdown report
    cat > reports/terraform-tflint-report.md << 'EOF'
# TFLint Report

## Summary
EOF
    
    if [ $tflint_exit_code -eq 0 ]; then
        {
            echo "✅ **Status**: PASSED - No TFLint issues found"
            echo ""
            echo "All Terraform files passed TFLint validation."
        } >> reports/terraform-tflint-report.md
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
        } >> reports/terraform-tflint-report.md
        
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
                } >> reports/terraform-tflint-report.md
            elif [[ -n "$line" ]]; then
                {
                    echo "\`\`\`"
                    echo "$line"
                    echo "\`\`\`"
                    echo ""
                } >> reports/terraform-tflint-report.md
            fi
        done < /tmp/tflint_output.txt
    fi
    
    echo "TFLint report generated: reports/terraform-tflint-report.md"
    return $tflint_exit_code
}

# Function to run other linters
run_shellcheck() {
    echo "Running ShellCheck..."
    
    if command -v shellcheck >/dev/null 2>&1; then
        find . -name "*.sh" -not -path "./.*" -print0 | xargs -0 shellcheck -f gcc > /tmp/shellcheck_output.txt 2>&1 || true
        
        cat > reports/bash-shellcheck-report.md << 'EOF'
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
            } >> reports/bash-shellcheck-report.md
        else
            echo "✅ **Status**: PASSED - No ShellCheck issues found" >> reports/bash-shellcheck-report.md
        fi
        
        echo "ShellCheck report generated: reports/bash-shellcheck-report.md"
    else
        echo "ShellCheck not found, skipping..."
    fi
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
        
        cat > reports/python-black-report.md << 'EOF'
# Python Black Report

## Summary
EOF
        
        if [ $black_exit_code -eq 0 ]; then
            echo "✅ **Status**: PASSED - No Python Black formatting issues found" >> reports/python-black-report.md
        else
            {
                echo "❌ **Status**: FAILED - Python Black formatting issues found"
                echo ""
                echo "## Issues Found"
                echo ""
                echo "\`\`\`diff"
                cat /tmp/black_output.txt
                echo "\`\`\`"
            } >> reports/python-black-report.md
        fi
        
        echo "Python Black report generated: reports/python-black-report.md"
    else
        echo "Python Black not found, skipping..."
    fi
}

# Main execution
case "${1:-all}" in
    "tflint"|"terraform-tflint")
        run_tflint
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
        echo "Usage: $0 [tflint|shellcheck|black|all]"
        echo "  tflint     - Run TFLint only"
        echo "  shellcheck - Run ShellCheck only"  
        echo "  black      - Run Python Black only"
        echo "  all        - Run all linters (default)"
        exit 1
        ;;
esac
