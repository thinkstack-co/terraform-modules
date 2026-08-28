# Upgrading a repo to terraform-modules v3 (VPC)

Applies to the `modules/aws/vpc` module only. Other modules are bumped independently.

v3 re-keys every per-AZ VPC resource. Which path you take depends entirely on what
your **live state** looks like, not on what your `.tf` files say.

---

## 1. Work out which band you are in

Two bands, and picking the wrong one is the only way to cause damage.

| Band                                         | Live state keys look like                  | What you do                                                                 |
| -------------------------------------------- | ------------------------------------------ | --------------------------------------------------------------------------- |
| **B — count-based** (module ref `<= v2.9.2`) | `aws_subnet.private_subnets[0]`            | Nothing. v3 ships `moved` blocks that migrate you automatically.            |
| **A — AZ-name keyed** (module ref `v2.10.0`) | `aws_subnet.private_subnets["us-east-1a"]` | A one-time `terraform state mv`, plus delete your consumer-side moved file. |

Determine it from state, which is authoritative:

```bash
terraform state list | grep 'aws_subnet.private_subnets'
```

> **Do not determine the band by grepping your `.tf` files.** A `?ref=v2.10.0` in the
> working tree proves nothing — the bump may be uncommitted or committed but never
> applied, leaving live state count-based. Check `git diff` and `git show HEAD:vpc.tf`
> against the working tree, and trust `terraform state list` over both.

A reliable secondary signal: Band A repos have a consumer-side moved file
(`vpc_moved.tf` or similar) containing `from = module.vpc.aws_subnet...[0]`. That file
was needed to _perform_ the v2.9.2 → v2.10.0 migration, so its presence and genuinely
being on v2.10.0 are the same fact seen twice.

---

## 2. Band B (count-based) — zero touch

1. Bump the ref to `v3.0.0`.
2. `terraform init -upgrade`
3. `terraform plan` — expect moves only, **no destroys and no creates**.
4. Apply.

The module's `moved.tf` maps `[N]` → `["N"]` for ordinals 0–5. Nothing else to do.

---

## 3. Band A (v2.10.0, AZ-name keyed) — state migration required

v3's shipped `moved.tf` covers only the count-based path. It does **not** cover AZ-name
keys, so without the steps below the plan destroys and recreates the entire network
layer — subnets, route tables, NAT gateways, EIPs, routes, associations.

### What skipping this actually costs

This was measured, not estimated. A real Band A repo whose VPC layer is **42 resources**
was pointed at v3 without the state migration. The resulting plan:

```
Resources: 89 to add, 8 to change, 82 to destroy
```

**82 destroys from a 42-resource VPC.** The cascade roughly doubles the damage, and it
does not stay inside the network layer. Terraform names the mechanism itself:

```
# module.<some_server>.aws_instance.ec2 must be replaced
  ~ subnet_id = "subnet-xxxxxxxx" -> (known after apply) # forces replacement
```

A replaced subnet has an unknown ID, and every resource consuming that ID is forced to
replace. In the repo tested it took out two application servers, their EBS volume attachments and
CloudWatch alarms, and pushed the ECS service and autoscaling group running the
**Terraform Cloud agents** onto unknown subnets — an apply that destroys the agents
performing the apply.

Assume the same shape anywhere: every EC2 instance, ENI, RDS instance, and load balancer
placed in a VPC subnet is in scope, not just the VPC's own resources.

### Prerequisites

- **AWS provider `>= 6.0.0`.** v3's VPC floor moved up. If you commit a lock file below
  that, `terraform init -upgrade` first and review the provider-upgrade diff separately,
  before starting this migration. Don't do both at once.
- Check whether `var.azs` is alphabetically sorted. If it is not, list outputs such as
  `private_route_table_ids` change order between v2.10 and v3 (v2.10 orders by AZ name,
  v3 by ordinal). Anything consuming those by index needs review first.
- Note your `var.azs` **in declaration order** — you will pass it to the script, and the
  ordinal is the AZ's index in that list, including any AZ currently disabled.

### Steps

**1. Delete the consumer-side moved file.**

```bash
git rm vpc_moved.tf     # whatever yours is called
```

Its blocks share a `from` address with v3's shipped `moved.tf` but declare a different
`to`, so Terraform aborts with _"Ambiguous move statements"_ — one error per block.

This is fail-closed: a hard error, never a silent destroy. But note **`terraform validate`
passes** — only `plan` catches it, so CI will not warn you.

If the file also contains moved blocks for _other_ modules, delete only the
`module.vpc` ones.

**1b. Sanity-check every remaining moved block before you plan.**

While you are in the moved files, confirm none of them point somewhere that no longer
exists. A one-character typo in a `to` address is silent: Terraform does not error, it
moves the state to the phantom address and then plans to **destroy** it, because it is
"not in configuration".

```bash
# every moved block whose 'from' module differs from its 'to' module
grep -A2 '^moved' *_moved.tf | grep -E 'from|to'

# every 'to' module that has no module block in the config
for m in $(grep -h 'to *= *module\.' *_moved.tf | sed 's/.*to *= *module\.//; s/\..*//' | sort -u); do
  grep -q "module \"$m\"" *.tf || echo "MISSING module block: $m"
done
```

A move is only harmless while its `from` address is absent from state. An
already-applied moved block is inert — but it becomes live again the moment you restore
a pre-migration state backup, which is exactly what step 4 creates.

**2. Bump the VPC ref, and only the VPC ref.**

```hcl
source = "github.com/thinkstack-co/terraform-modules//modules/aws/vpc?ref=v3.0.0"
```

Leave every other module at its current ref. Bumping others at the same time makes a
non-empty plan impossible to interpret.

**3. Re-initialise.**

```bash
terraform init -upgrade
```

**4. Back up state. Do not skip this.**

```bash
terraform state pull > v3-state-backup.tfstate
```

**5. Dry-run the migration.**

```bash
bash v3-state-migrate.sh module.vpc us-east-1a us-east-1b us-east-1c
```

Prints the `terraform state mv` commands without touching anything. Read the list. Every
AZ-name key should map to its index in `var.azs` — with a disabled middle AZ you should
see `0` and `2`, not `0` and `1`.

**6. Apply the migration.**

```bash
bash v3-state-migrate.sh module.vpc us-east-1a us-east-1b us-east-1c --apply
```

One state write per resource, each its own API round-trip and state lock. Measured:
42 moves took just over two minutes against _local_ state, and remote state is slower.
It will look like it has hung. It has not — let it finish.

**7. Verify — this is the gate.**

```bash
terraform plan
```

**Expect zero `module.vpc` actions** — no destroys, no creates, no in-place changes
inside the VPC module.

The plan as a whole may not be empty, because most repos carry unrelated pre-existing
drift. Do not try to judge that by eye. Capture a **control plan before you start** —
the unmodified repo, VPC still at v2.10.0 — and require the post-migration plan to match
it exactly:

```bash
# before any changes
terraform plan -no-color > control-plan.txt 2>&1

# after the migration, from the v3 branch
terraform plan -no-color > green-plan.txt 2>&1

grep -E '^  # ' control-plan.txt | sed 's/^  # //' | sort > /tmp/control.list
grep -E '^  # ' green-plan.txt   | sed 's/^  # //' | sort > /tmp/green.list
diff /tmp/control.list /tmp/green.list   # must be empty
```

An empty diff means the migration contributed nothing, which is the whole goal. Without
the control you cannot tell a migration defect from drift that was already there.

The v2.10 → v3 delta is purely state addressing: `Name` tags move from `each.key` to
`each.value.az`, which resolves to the identical string; CIDRs, AZs, and outputs are
unchanged.

**If the plan shows any destroy, stop and roll back:**

```bash
terraform state push v3-state-backup.tfstate
```

**8. Merge promptly — there is an open window.**

Between the `state mv` and the merge, live state is ordinal-keyed while your default
branch still holds v2.10 config. Anyone who plans or applies the default branch in that
gap gets the full destroy plan, just from the other direction. Keep the window short and
tell anyone else working in that repo.

Then apply through the normal review flow. The apply covers only whatever pre-existing
drift the control plan showed — review that on its own merits, since it is not part of
this migration.

---

## 4. What each check is actually protecting you from

| Symptom                                      | Cause                                            | Fix                                     |
| -------------------------------------------- | ------------------------------------------------ | --------------------------------------- |
| `Ambiguous move statements`                  | Consumer moved file still present                | Step 1                                  |
| Plan destroys/recreates the network layer    | State mv not run, or ran with the wrong AZ order | Restore backup, redo steps 5–6          |
| `Unsupported attribute` on `data.aws_region` | Provider below 6.0.0                             | `terraform init -upgrade`               |
| List-output consumers see reordered IDs      | `var.azs` not alphabetically sorted              | Review those consumers before migrating |

---

## 5. Rollback

Before apply, rollback is total — `terraform state push` the backup and revert the ref.
Nothing has been changed in AWS at any point; every step up to the final apply touches
only Terraform state.

---

## Validation status of this document

Verified against a real Band A repo (2 AZs, 6 subnet types, firewall enabled, NAT
disabled) using a copy of its live production state:

- **Band detection.** Live state held exactly 42 AZ-name-keyed instances, matching both
  the consumer moved file's block count and an independent derivation from module
  configuration.
- **The ambiguity collision.** 42 moved blocks produced exactly 42 `Ambiguous move
statements` errors. Removing the file cleared all of them. `terraform validate` passed
  in both cases — only `plan` catches it.
- **The migration.** 42/42 `state mv` operations succeeded, 0 failures. Afterwards: 0
  AZ-name keys remained, 42 ordinal keys existed, and every ordinal held the resource
  for the AZ that v3 assigns to that ordinal.
- **Attribute equivalence**, checked offline against what v3's configuration computes:
  36/36 subnet attributes (AZ, CIDR, `Name` tag), 10/10 route-table `Name` tags, 10/10
  association `subnet_id` wirings, and 10/10 firewall-route `route_table_id` values —
  no differences. The singular `public_route_table` was correctly left un-keyed.

**End-to-end, on a live production workspace.** The same repo was migrated for real:
42/42 moves applied (state serial 789 -> 831, resource count unchanged at 296, zero
AZ-name keys remaining, 42 ordinal keys present). The post-migration plan was then
compared to a control plan taken beforehand:

| Run                         | add | change | destroy | `module.vpc` actions |
| --------------------------- | --- | ------ | ------- | -------------------- |
| Control (v2.10, unmodified) | 7   | 11     | 0       | 0                    |
| Hazard (v3, no state mv)    | 89  | 8      | 82      | many                 |
| Green (v3, after state mv)  | 7   | 11     | 0       | 0                    |

All 18 planned action lines in the green run were **identical** to the control. The
migration contributed nothing to the plan, which is exactly the intended result.

Remaining caveat: this was one repo, with 2 AZs, six subnet types, a firewall and NAT
disabled. Repos with NAT gateways, EIPs, S3 endpoint associations, or a disabled middle
AZ exercise code paths that were verified by inspection but not yet by a live migration.
Keep taking a control plan for each repo.
