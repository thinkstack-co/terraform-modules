# Local Linting Setup for terraform-modules

This guide helps you set up local linting to catch errors before pushing to GitHub.

## Quick Start

### 1. Install Required Tools

```bash
# Install Python linters
pip install -r requirements-lint.txt

# Install other linters (macOS with Homebrew)
brew install pre-commit hadolint tflint gitleaks

# Install jscpd for duplicate code detection
npm install -g jscpd
```

### 2. Run Linting

```bash
# Option 1: Run all linters on current directory
./lint-local.sh

# Option 2: Run all linters on specific path
./lint-local.sh modules/aws/config/

# Option 3: Use pre-commit (recommended)
pre-commit install  # One-time setup
pre-commit run --all-files  # Run on all files
pre-commit run  # Run on staged files only
```

## Manual Linting Commands

If you prefer to run linters individually:

### Python
```bash
# Format code
black --line-length 120 *.py

# Sort imports
isort --profile black --line-length 120 *.py

# Check style
flake8 --max-line-length=120 --extend-ignore=E203 *.py

# Type checking
mypy --ignore-missing-imports *.py

# Code quality
pylint --max-line-length=120 --disable=C0114,C0115,C0116 *.py
```

### Terraform
```bash
# Run in directory with .tf files
tflint --format=compact
```

### Dockerfile
```bash
hadolint Dockerfile
```

### Secret Scanning
```bash
gitleaks detect --verbose
```

## VS Code Integration

Add to `.vscode/settings.json`:

```json
{
  "python.linting.enabled": true,
  "python.linting.flake8Enabled": true,
  "python.linting.pylintEnabled": true,
  "python.formatting.provider": "black",
  "python.formatting.blackArgs": ["--line-length", "120"],
  "[python]": {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": true
    }
  }
}
```

## Troubleshooting

### Python Type Errors
- Missing type stubs: Run `pip install types-<package>` for the package
- Use `--ignore-missing-imports` flag with mypy

### Terraform Errors
- Ensure you run tflint from a directory containing `.tf` files
- Check `.tflint.hcl` for custom rules

### Pre-commit Issues
- Update hooks: `pre-commit autoupdate`
- Clear cache: `pre-commit clean`
- Skip hook: `SKIP=hook-name git commit`

## CI/CD Alignment

These local linters match what GitHub Super-Linter runs in CI/CD:
- Python: black, isort, flake8, mypy, pylint
- Terraform: tflint
- Docker: hadolint
- Secrets: gitleaks
- Duplicates: jscpd

Running `./lint-local.sh` before pushing will catch most issues that would fail in CI.