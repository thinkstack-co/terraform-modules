# GitHub Actions Workflows

## Super-Linter Workflow

The `super-linter.yml` workflow automatically runs linters on your code when you push to the repository or create a pull request.

### Triggers

- **Push**: Runs on pushes to `main` branch and any branch starting with `v*` (version branches)
- **Pull Request**: Runs on pull requests targeting the `main` branch

### Linters Enabled

The workflow **automatically detects and runs ALL available linters** for any code it finds. This includes 50+ linters for:

#### Infrastructure as Code

- **Terraform**: fmt, tflint (uses `.tflint.hcl`)
- **Ansible**: ansible-lint
- **CloudFormation**: cfn-lint
- **Kubernetes**: kubeval
- **Docker**: hadolint

#### Programming Languages

- **Python**: black, flake8, isort, mypy, pylint (uses `.flake8`, `.isort.cfg`)
- **JavaScript/TypeScript**: eslint, prettier, standard
- **Go**: golangci-lint
- **Ruby**: rubocop
- **Java**: checkstyle
- **C/C++**: cpplint, clang-format
- **Rust**: rustfmt, clippy
- **PHP**: phpstan, psalm
- **Shell/Bash**: shellcheck, shfmt

#### Data & Config Files

- **JSON**: jsonlint
- **YAML**: yamllint
- **XML**: xmllint
- **TOML**: taplo
- **Markdown**: markdownlint

#### Security & Quality

- **Gitleaks**: Secret scanning
- **JSCPD**: Copy-paste detection
- **SQL**: sqlfluff
- **Protobuf**: protolint

**Note:** Super-Linter automatically detects which languages are present in your repository and only runs relevant linters.

### Configuration Files

The linters use the following configuration files in the repository root:

- `.tflint.hcl` - TFLint configuration
- `.flake8` - Flake8 configuration
- `.python-black` - Black formatter configuration
- `.isort.cfg` - isort configuration
- `.blackignore` - Files to exclude from Black formatting

### Disabling Specific Linters (Optional)

All linters are enabled by default. If you need to disable a specific linter, edit `.github/workflows/super-linter.yml` and add:

```yaml
VALIDATE_<LINTER_NAME>: false
```

For example, to disable copy-paste detection:

```yaml
VALIDATE_JSCPD: false
```

Common linters you might want to disable:

- **JSCPD**: Copy-paste detection (can be noisy for similar infrastructure code)
- **PYTHON_PYLINT**: Can be overly strict (if you prefer flake8 only)

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
