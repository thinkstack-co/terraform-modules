#!/usr/bin/env bash
# Script:  run-superlinter.sh
# Purpose: Run super-linter locally in Docker, mirroring the config in
#          .github/workflows/super-linter.yml so local results match CI.
# Inputs:  none — reads .tflint.hcl, .flake8, .gitleaks.toml from repo root.
# Outputs: ./lint-reports/<timestamp>/  — full log + per-linter logs from
#          super-linter's CREATE_LOG_FILE option.
# Notes:   Requires Docker Desktop running. Pulls ghcr.io/super-linter/super-linter:v7
#          (~6 GB) on first run. ./lint-reports/ is gitignored.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
REPORT_DIR="${REPO_ROOT}/lint-reports/${TIMESTAMP}"
mkdir -p "${REPORT_DIR}"

echo "Super-Linter local run"
echo "  repo:    ${REPO_ROOT}"
echo "  reports: ${REPORT_DIR}"
echo

# Why: env vars below mirror .github/workflows/super-linter.yml exactly so a
#      pass locally implies a pass in CI. RUN_LOCAL=true and the volume mount
#      are the only local-only additions.
docker run --rm \
	-e RUN_LOCAL=true \
	-e VALIDATE_ALL_CODEBASE=true \
	-e DEFAULT_BRANCH=main \
	-e TERRAFORM_TFLINT_CONFIG_FILE=.tflint.hcl \
	-e PYTHON_FLAKE8_CONFIG_FILE=.flake8 \
	-e LOG_LEVEL=NOTICE \
	-e CREATE_LOG_FILE=true \
	-e LOG_FILE=super-linter.log \
	-e SAVE_SUPER_LINTER_OUTPUT=true \
	-e SUPER_LINTER_OUTPUT_DIRECTORY_NAME="lint-reports/${TIMESTAMP}/super-linter-output" \
	-e FILTER_REGEX_EXCLUDE='.*/(\.terraform|\.venv|venv|node_modules|package|lint-reports)/.*' \
	-v "${REPO_ROOT}":/tmp/lint \
	ghcr.io/super-linter/super-linter:v7 \
	2>&1 | tee "${REPORT_DIR}/console.log"

EXIT_CODE="${PIPESTATUS[0]}"

# Move super-linter's own log into the timestamped dir so reruns don't clobber.
if [[ -f "${REPO_ROOT}/super-linter.log" ]]; then
	mv "${REPO_ROOT}/super-linter.log" "${REPORT_DIR}/super-linter.log"
fi

echo
echo "Done. Exit code: ${EXIT_CODE}"
echo "Reports: ${REPORT_DIR}"
exit "${EXIT_CODE}"
