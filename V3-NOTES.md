# v3 Release Notes & Deferred Work

Status as of 2026-08-27. This file records what v3 changed, what was deliberately
left undone, and the traps a maintainer will hit if they don't know about them.

---

## 1. Breaking changes for consumers

### Provider floors were corrected (25 modules)

Many modules declared `aws >= 4.0.0` while actually requiring 5.x or 6.x features.
The declared floors were verified empirically — each module was pinned to an exact
provider version and run through `terraform init` + `validate`, walking 4.0.0 → 5.0.0
→ 6.0.0 → 6.10.0 → 6.62.0. The lowest version that validates is the recorded floor.

**This does not create new breakage — it labels breakage that already existed.**
`modules/aws/vpc` uses `data.aws_region.current.region` in ~14 places; that attribute
does not exist before provider 6.x. A repo on provider 5.x consuming v3's vpc fails
either way. The corrected floor turns a cryptic `Unsupported attribute` error deep in
a locals block into a clear version-constraint error at `init`.

| Now requires | Modules                                                                                                                                                                                                                           |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `>= 6.0.0`   | `vpc`, `cloudtrail`, `flow_logs`, `vendor/appgate`                                                                                                                                                                                |
| `>= 5.0.0`   | `ebs_volume`, `eip`, `ec2_domain_controller`, `transit_gateway`, `acm_certificate`, `launch_template`, `rds/cluster`, `organizations_account`, `transit_gateway_connect`, `transit_gateway_connect_peer`, `s3/s3_with_transition` |

**Repos that must upgrade their provider before consuming v3** (from their committed
lock files — repos without a committed lock resolve to the newest matching version and
need no action):

| Repo                             | Locked at | Blocked on           |
| -------------------------------- | --------- | -------------------- |
| `vermontfcu_prod_infrastructure` | 3.44.0    | cloudtrail           |
| `liberty_prod_sdwan`             | 4.11.0    | vpc, transit_gateway |
| `solarity_prod_api`              | 4.58.0    | vpc                  |
| `alps_prod_infrastructure`       | 5.22.0    | vpc                  |
| `christian_prod_infrastructure`  | 5.25.0    | vpc, cloudtrail      |
| `mutual_prod_infrastructure`     | 5.97.0    | vpc, cloudtrail      |

Fix per repo: `terraform init -upgrade`. Note this crosses provider majors for the
first three (3.x/4.x → 6.x), so expect plan diffs from the provider upgrade itself and
review them before applying.

Caveat: only 19 of ~110 Terraform repos commit a lock file, so the table above is a
**floor, not a ceiling**. Repos not checked out locally, or whose provider version is
resolved at TFC run time, could not be assessed.

### `vendor/silverpeak`: `count` variable renamed

`variable "count"` is a reserved name and made the module fail `terraform validate`
outright. Renamed to `instance_count`. Any caller passing `count = N` must switch to
`instance_count = N`. Fleet grep found zero consumers, so nothing breaks today.

---

## 2. Traps a maintainer will hit

### `.terraform.lock.hcl` files are committed in ~96 module dirs and 83 pin aws 6.9.0

Terraform reads the dependency lock file of the **root module only** — a consumer
pulling `?ref=v3.0.0` reads this repo's `required_providers` constraint and ignores
these lock files completely. They pin nothing for anyone. They matter only because CI
inits each module dir as if it were a root module.

They are actively harmful there: when a module's floor is raised above its lock's
pinned version, `terraform init` fails with _"locked provider ... does not match
configured version constraint"_. This is exactly what happened to
`vendor/fortigate_firewall` (floor moved to `>= 6.10.0`, lock still said 6.9.0).

**Mitigated** by adding `-upgrade` to the init in `.github/workflows/terraform-validate.yml`,
which re-resolves within constraints and ignores the stale pin. The locks are now
decorative — they claim 6.9.0 while CI tests the newest matching version.

**The cleaner end state** is to `git rm --cached` them and add to `.gitignore`, which
also requires updating the module-file convention in `.claude/CLAUDE.md` (it currently
lists `.terraform.lock.hcl` as a standard module file, so the next module will
reintroduce them). Not urgent now that `-upgrade` is in place.

Second footgun if you do regenerate any: a lock generated on macOS records only a
`darwin_arm64` hash and CI runs `linux_amd64`. Use
`terraform providers lock -platform=linux_amd64 -platform=darwin_arm64`, not a plain
`init`.

### Three modules can never pass a standalone `init` + `validate`

`thinkstack/aws_backup`, `thinkstack/aws_backup_custom`, and
`thinkstack/aws_backup_custom/modules/aws_backup_vault` declare
`configuration_aliases`, so they require a caller to pass aliased providers. Validating
them as a root module always fails with _"Provider configuration not present"_ — this
is not a defect.

`terraform-validate.yml` currently scopes to `MODULE_ROOT: modules/aws` and therefore
misses them. **Widening it to `modules` — as its own header comment suggests — will
break CI on these three.** Any such change needs an explicit skip for modules
containing `configuration_aliases`.

---

## 3. Deferred work, highest value first

### `ssm_role` attaches a deprecated AWS managed policy — 17 consumers

`modules/aws/ssm_role/main.tf` attaches `AmazonEC2RoleforSSM`, which AWS deprecated.
It grants broad `s3:*`, which is the data-exfiltration path AWS deprecated it for.
Should be `AmazonSSMManagedInstanceCore`.

Deferred because it changes IAM behavior across 17 repos and wants someone available
to watch the rollout. Also worth fixing while in there: the role and instance profile
names are hardcoded to `ssm-service-role` (so two deployments in one account collide),
the module accepts no variables, and it sets no tags — violating the repo tagging
standard.

### `ec2_instance` defaults to IMDSv1

`http_tokens` defaults to `"optional"`. Every other instance module in the repo
(`ec2_domain_controller`, `launch_template`, all four vendor appliance modules)
defaults to `"required"`. This is the fleet's most-used instance module, so it leaves
IMDSv1 enabled by default. Flipping a default is a breaking change and belongs in a
major version — v3 was the natural window and it was not taken.

### S3 legacy modules block lifting the `< 7.0.0` ceiling

`s3/s3_legacy`, `s3/s3_with_transition`, and `s3/s3_website` use inline
`aws_s3_bucket` blocks (`acl`, `versioning`, `server_side_encryption_configuration`,
`lifecycle_rule`) that are deprecated in 6.x and **removed in provider 7.0**. The
modern shape is the `s3/bucket` submodule.

AWS provider 7.0 was not released as of 2026-08-27 (latest 6.62.0), so there is
runway — but only two repos consume these: `coastlife_prod_infrastructure` (s3_legacy)
and `lorien_prod_infrastructure` (s3_with_transition, at the old pre-move path
`modules/aws/s3_with_transition` pinned to `?ref=v1.4.2`). Two repos is a manageable
migration; under v7 pressure it will not be.

Related: `aws_s3_bucket_acl` without `aws_s3_bucket_ownership_controls` fails on any
bucket created after Apr 2023 (`AccessControlListNotSupported`). Still present in
`s3/bucket`, `cloudtrail`, and `thinkstack/siem`.

### Remaining wrong provider floors (low consumer count)

Verified but not applied: `s3/bucket` → 5.0.0 (5 consumers), `aws_cost_report` → 6.0.0
(5), `thinkstack/siem` → 6.0.0 (4), `sqs_queue` → 6.0.0 (2), and a 1-consumer tail
(`netcov/appgate_sdp`, `s3/s3_legacy`, `network_diagram_generator`, `fsx`, `config`,
`alb/alb_ssl_cert`).

### Other known gaps

- Buckets created without `public_access_block`: `config`, `s3/s3_legacy`,
  `s3/s3_website`, `network_diagram_generator`. The `config` bucket also never enables
  versioning, so its noncurrent-version lifecycle rules are silent no-ops.
- 24 modules ship an empty `outputs.tf` and return nothing, so they cannot be composed.
- `.checkov.yaml` carries 14 "review candidate" skips (IAM wildcard `CKV_AWS_273/274/40/
356/355/290/111/108`, open-SG `CKV_AWS_382/277/24/260/25`, `CKV2_AWS_12`). Several map
  onto the `ssm_role` and vendor-SG items above; fixing those lets the skips be deleted
  rather than carried.
- No terraform-docs job, so the ~134 templated READMEs drift from actual variables.

---

## 4. How to re-run the verification

Two scripts were used and are worth recreating if this needs redoing.

**Merge gate** — mirrors `terraform-validate.yml` exactly (fmt + init/validate over
every dir under `modules/aws`, using committed locks). Last run: **fmt PASS, 0 failures
across 84 module dirs.**

**Floor sweep** — determines each module's true minimum provider version by pinning an
exact version and walking the ladder upward.

If you rebuild the floor sweep, three non-obvious things will otherwise give you
confident, wrong answers:

1. **An `init` failure is not a version incompatibility.** A transient registry or
   download failure looks identical and will invent a false floor. Retry init, and keep
   `INIT_FAIL` / `VALIDATE_FAIL` / `VALIDATE_OK` distinct.
2. **Copy the whole module directory, not just `*.tf`** — modules read sibling files via
   `file()` (`azure_ad_sso` needs `azure-ad-sso-policy.json`, `siem` needs
   `snypr_centos_script.sh`). But **exclude `.terraform.lock.hcl`**, or the copied lock
   overrides your version pin and silently defeats the test.
3. **Detect `configuration_aliases` and skip those modules** (see §2).

Always set `TF_PLUGIN_CACHE_DIR`; without it every module re-downloads the provider and
a full pass takes hours instead of minutes.
