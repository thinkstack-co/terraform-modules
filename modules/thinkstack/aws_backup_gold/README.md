# thinkstack / aws_backup_gold (experimental)

This module is an **experimental playground** for designing a new AWS Backup strategy that:

- **Combines Hourly, Daily, and Monthly rules into a single \"Gold\" backup plan**
- Uses **tag-based selection** for specific resources/servers
- Mirrors the original `thinkstack/aws_backup` behavior for non-EC2 resources, where one plan contained multiple rules.

## Status

- Creates a single AWS Backup plan with hourly, daily, and monthly rules.
- Uses a custom tag key/value to select resources into that plan.
- Optionally copies backups to a DR vault with independent retention settings.

## Intended Design (high level)

- **One Gold plan** with multiple `rule {}` blocks (hourly + daily + monthly).
- A **single selection** targeting tagged resources via a configurable tag key/value.
- DR copy actions with custom retention days for both primary and DR copies.

Implementation will be added incrementally as we iterate on the design.
