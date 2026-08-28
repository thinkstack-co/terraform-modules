#!/usr/bin/env bash
# Purpose:       Re-key a VPC module's Terraform state from the v2.10.0 AZ-name
#                keys (["us-east-1a"]) to the v3 ordinal keys (["0"]). Required
#                for any repo already on modules/aws/vpc?ref=v2.10.0 before it
#                bumps to v3 — v3's shipped moved.tf only covers the count-based
#                (<=v2.9.2) path, so without this the plan destroys and recreates
#                the whole network layer (subnets, RTs, NAT GWs, EIPs, routes,
#                associations).
# Inputs:        $1     = module address, e.g. module.vpc
#                $2..$N = the AZ list in var.azs ORDER, e.g. us-east-1a us-east-1b
#                         Must match the repo's var.azs exactly, including any AZ
#                         that is currently disabled — the ordinal is the AZ's
#                         index in var.azs, not its position among live keys.
#                --apply  execute the moves (default is dry-run: print only)
# Outputs:       The terraform state mv commands, then a per-move PASS/FAIL log
#                when --apply is given.
# Side effects:  NONE in dry-run. With --apply, writes to the workspace's state
#                (one state write + lock per move). Takes a full state backup to
#                $V3_BACKUP_DIR (default ~/.terraform-v3-backups) before the first
#                move — deliberately NOT the config dir, since state holds secrets
#                and anything beside the .tf files gets uploaded to TFC.
# Run in:        The consumer repo root, AFTER the module ref is bumped to
#                v3.0.0 and `terraform init -upgrade` has run, BEFORE any apply.
# Why not a consumer-side vpc_moved.tf: a consumer move ["us-east-1a"]->["0"]
#                and the module's shipped move [0]->["0"] both target ["0"], which
#                Terraform rejects as "Ambiguous move statements". A state mv is a
#                direct state operation and does not collide with a moved block.
# Compatibility: written for bash 3.2 (the macOS system bash) — no mapfile, no
#                associative arrays.
set -euo pipefail

APPLY=0
ARGS=()
for a in "$@"; do
	if [ "$a" = "--apply" ]; then APPLY=1; else ARGS+=("$a"); fi
done

if [ "${#ARGS[@]}" -lt 2 ]; then
	echo "Usage: bash $0 <module-address> <az1> <az2> [az3...] [--apply]"
	echo "Example: bash $0 module.vpc us-east-1a us-east-1b us-east-1c"
	echo
	echo "Read var.azs from the repo's VPC module call and pass it in the SAME order."
	exit 1
fi

MODULE_ADDR="${ARGS[0]}"
AZS=("${ARGS[@]:1}")

echo "Module address: $MODULE_ADDR"
echo "AZ order:       ${AZS[*]}"
echo

# Ordinal lookup by linear scan of the caller-supplied var.azs order. bash 3.2
# has no associative arrays, and the list is at most a handful of AZs.
# Echoes the index, or nothing when the AZ is not in the list.
ordinal_of() {
	local want="$1" i
	for i in $(seq 0 $((${#AZS[@]} - 1))); do
		if [ "${AZS[$i]}" = "$want" ]; then
			echo "$i"
			return 0
		fi
	done
	return 1
}

# Every address under the module whose instance key is an AZ name. Matching on
# the key shape rather than a hardcoded resource list means this covers all of
# the re-keyed families (subnets, route tables, NAT/FW default routes, EIPs,
# NAT GWs, S3 endpoint RT associations, subnet RT associations) without needing
# to stay in sync with the module.
ADDRS=()
while IFS= read -r line; do
	[ -n "$line" ] && ADDRS+=("$line")
done < <(
	terraform state list |
		grep -E "^${MODULE_ADDR//./\\.}\..*\[\"[a-z]{2}-[a-z]+-[0-9][a-z]\"\]$" || true
)

if [ "${#ADDRS[@]}" -eq 0 ]; then
	echo "No AZ-name-keyed addresses found under $MODULE_ADDR."
	echo "Either this repo is not on v2.10.0, or the module address is wrong."
	echo "Check with: terraform state list | grep aws_subnet"
	exit 0
fi

echo "Found ${#ADDRS[@]} AZ-name-keyed resources to re-key."
echo

# Build the full move list first so an unknown AZ aborts before any state is
# touched. FROMS[i] pairs with TOS[i].
FROMS=()
TOS=()
for from in "${ADDRS[@]}"; do
	# Extract the AZ name out of the trailing ["..."] instance key.
	az="${from##*[\"}"
	az="${az%%\"]*}"
	# NOTE: the brackets in the suffix pattern MUST be backslash-escaped. Bash
	# reads an unescaped [...] as a character class, so the strip silently
	# no-ops and the move target comes out doubly-keyed.
	if ! ord="$(ordinal_of "$az")"; then
		echo "ERROR: state contains AZ '$az', which is not in the var.azs list you passed."
		echo "       Pass the repo's full var.azs, in order, including disabled AZs."
		exit 1
	fi
	FROMS+=("$from")
	TOS+=("${from%\[\""$az"\"\]}[\"$ord\"]")
done

echo "--- Planned moves ---"
for i in $(seq 0 $((${#FROMS[@]} - 1))); do
	printf "terraform state mv '%s' '%s'\n" "${FROMS[$i]}" "${TOS[$i]}"
done
echo

if [ "$APPLY" -eq 0 ]; then
	echo "=================================================================="
	echo "DRY RUN — no state was modified."
	echo "Review the moves above, then re-run with --apply to execute."
	echo "=================================================================="
	exit 0
fi

# Full state backup before the first write. One file per workspace so repeated
# runs across repos don't clobber each other.
#
# Written OUTSIDE the Terraform config directory on purpose. A state file left in
# the working directory is uploaded to TFC as part of the configuration version on
# the next run, and would be committed if the directory is a repo. State contains
# secrets, so it must not sit next to the .tf files.
BACKUP_DIR="${V3_BACKUP_DIR:-$HOME/.terraform-v3-backups}"
mkdir -p "$BACKUP_DIR"
WS="$(terraform workspace show 2>/dev/null || echo default)"
BACKUP="$BACKUP_DIR/v3-state-backup-${WS}-$(date +%Y%m%d-%H%M%S).tfstate"
echo "Backing up state to $BACKUP"
terraform state pull >"$BACKUP"
echo "Backed up $(wc -c <"$BACKUP" | tr -d ' ') bytes."
echo

# Sequential moves. Each is its own state write + lock against the remote
# backend, so this is slow — expect a few seconds per resource.
FAILED=0
for i in $(seq 0 $((${#FROMS[@]} - 1))); do
	printf "[%d/%d] %s\n" "$((i + 1))" "${#FROMS[@]}" "${TOS[$i]}"
	if terraform state mv "${FROMS[$i]}" "${TOS[$i]}"; then
		echo "  PASS"
	else
		echo "  FAIL"
		FAILED=$((FAILED + 1))
	fi
done

echo
echo "=================================================================="
if [ "$FAILED" -eq 0 ]; then
	echo "All ${#FROMS[@]} moves applied."
	echo "Next: terraform plan — the network layer should show NO destroys and"
	echo "NO creates. If it shows destroys, STOP and restore:"
	echo "  terraform state push \"$BACKUP\""
else
	echo "$FAILED of ${#FROMS[@]} moves FAILED — state is partially migrated."
	echo "Do NOT apply. Restore with:"
	echo "  terraform state push \"$BACKUP\""
fi
echo "=================================================================="
