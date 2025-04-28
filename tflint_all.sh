#!/bin/bash
# tflint_all.sh - Recursively run tflint on all Terraform modules and output an organized report

REPO_ROOT="$(cd "$(dirname "$0")"; pwd)"
REPORT_FILE="$REPO_ROOT/tflint-report.txt"
TMP_FILE="$(mktemp)"

echo "# TFLint Issues Report (Organized by Directory & Rule)" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Generated on: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Only run tflint in directories that contain a main.tf file (i.e., actual module roots)
find "$REPO_ROOT" -type f -name "main.tf" | while read -r main_tf; do
  dir="$(dirname "$main_tf")"
  rel_dir="${dir#$REPO_ROOT/}"
  echo "## Directory: ${rel_dir:-.}" >> "$REPORT_FILE"

  # Run TFLint and capture both stdout and stderr
  tflint_output=$(cd "$dir" && tflint --format compact 2>&1)

  if [[ -z "$tflint_output" ]]; then
    echo "No issues found." >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    continue
  fi

  # Organize by rule
  echo "$tflint_output" > "$TMP_FILE"
  grep -oE '\[([a-zA-Z0-9_]+)\]' "$TMP_FILE" | sort | uniq | while read -r rule; do
    rule_clean=$(echo "$rule" | tr -d '[]')
    echo "### Rule: $rule_clean" >> "$REPORT_FILE"
    grep "$rule" "$TMP_FILE" | nl -w2 -s'. ' >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
  done

  # Show any lines that don't match a rule (e.g., errors)
  grep -vE '\[[a-zA-Z0-9_]+\]' "$TMP_FILE" | grep -v '^$' | while read -r line; do
    echo "ERROR/INFO: $line" >> "$REPORT_FILE"
  done
  echo "" >> "$REPORT_FILE"
done

rm -f "$TMP_FILE"

echo "TFLint report generated at $REPORT_FILE"