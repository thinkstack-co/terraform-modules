# GitHub Actions Workflows

## Super-Linter Workflow

The `super-linter.yml` workflow automatically runs linters on your code when you push to the repository or create a pull request.

### Triggers

- **Push**: Runs on pushes to `main` branch and any branch starting with `v*` (version branches)
- **Pull Request**: Runs on pull requests targeting the `main` branch

### Linters Enabled

The workflow validates the following:

#### Terraform

- **terraform fmt**: Checks Terraform formatting
- **tflint**: Runs TFLint with configuration from `.tflint.hcl`

#### Python

- **black**: Code formatting (line-length=120)
- **flake8**: Style guide enforcement (configured in `.flake8`)
- **isort**: Import sorting (configured in `.isort.cfg`)
- **mypy**: Static type checking
- **pylint**: Code analysis

#### Other Languages

- **JSON**: JSON syntax validation
- **YAML**: YAML syntax validation
- **Markdown**: Markdown linting
- **Bash**: Shell script linting and executable validation

### Configuration Files

The linters use the following configuration files in the repository root:

- `.tflint.hcl` - TFLint configuration
- `.flake8` - Flake8 configuration
- `.python-black` - Black formatter configuration
- `.isort.cfg` - isort configuration
- `.blackignore` - Files to exclude from Black formatting

### Disabled Linters

The following linters are disabled to avoid duplication or noise:

- **JSCPD**: Copy-paste detection (can be noisy)
- **Gitleaks**: Secret scanning (handled separately)

### Viewing Results

1. Go to the **Actions** tab in your GitHub repository
2. Click on the workflow run to see detailed results
3. Each linter will show as a separate check with pass/fail status
4. Click on a failed check to see specific errors and line numbers

### Local Testing

Before pushing, you can run linters locally using:

```bash
# Run all linters
./run-linters.sh

# Or use pre-commit hooks
pre-commit run --all-files
```

### Troubleshooting

If the workflow fails:

1. Check the specific linter that failed in the Actions tab
2. Run the same linter locally to reproduce the issue
3. Fix the issues and push again
4. The workflow will automatically re-run on the new push

### Customization

To modify linter settings:

1. Edit `.github/workflows/super-linter.yml`
2. Add or remove `VALIDATE_*` environment variables
3. Update configuration files in the repository root
4. Commit and push changes
