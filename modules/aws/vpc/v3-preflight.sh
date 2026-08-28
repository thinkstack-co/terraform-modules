#!/usr/bin/env bash
# Purpose:       Pre-flight safety check to run BEFORE upgrading a VPC to the
#                terraform-modules v3 VPC module. v3 adopts and locks the VPC's
#                default security group to zero rules by default
#                (manage_default_security_group=true). This script reports
#                whether that lockdown is safe for a given VPC by listing
#                anything currently attached to the default SG, and dumps the
#                rules the lockdown would strip.
# Inputs:        $1 = VPC ID (vpc-xxxxxxxx) OR the VPC's Name tag value.
#                     If omitted, lists VPCs in the account/region so you can pick.
# Outputs:       default SG id, ENIs using it (with owners), current rules,
#                and a SAFE / REVIEW verdict.
# Side effects:  NONE. Every AWS call is a read-only describe operation.
# Run in:        AWS CloudShell (or any authed shell) in the TARGET account and
#                region — e.g. the account/region where the VPC lives.
set -euo pipefail

VPC_ID="${1:-}"

# No argument: list VPCs in this account/region and exit.
if [[ -z "$VPC_ID" ]]; then
	echo "No VPC given. VPCs in this account/region:"
	# shellcheck disable=SC2016  # backticks are JMESPath literal syntax, not shell expansion
	aws ec2 describe-vpcs \
		--query 'Vpcs[].{VPC:VpcId,CIDR:CidrBlock,Name:Tags[?Key==`Name`]|[0].Value}' \
		--output table
	echo
	echo "Re-run:  bash $0 <vpc-id | vpc-Name-tag>"
	exit 0
fi

# Allow passing the VPC's Name tag instead of a vpc- id.
if [[ "$VPC_ID" != vpc-* ]]; then
	echo "Resolving VPC by Name tag: $VPC_ID"
	VPC_ID=$(aws ec2 describe-vpcs \
		--filters "Name=tag:Name,Values=$VPC_ID" \
		--query 'Vpcs[0].VpcId' --output text)
	if [[ "$VPC_ID" == "None" || -z "$VPC_ID" ]]; then
		echo "ERROR: no VPC found with that Name tag in this account/region."
		exit 1
	fi
fi

echo "=== VPC: $VPC_ID ==="

# The VPC's default security group — AWS auto-creates exactly one per VPC.
DEFAULT_SG=$(aws ec2 describe-security-groups \
	--filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=default" \
	--query 'SecurityGroups[0].GroupId' --output text)
echo "Default security group: $DEFAULT_SG"
echo

# Anything attached to the default SG would lose its allow-all rules when locked.
echo "--- ENIs currently using the default SG (empty table = safe to lock) ---"
aws ec2 describe-network-interfaces \
	--filters "Name=group-id,Values=$DEFAULT_SG" \
	--query 'NetworkInterfaces[].{ENI:NetworkInterfaceId,Type:InterfaceType,Desc:Description,Instance:Attachment.InstanceId,PrivateIP:PrivateIpAddress,Status:Status}' \
	--output table

# Count drives the verdict.
COUNT=$(aws ec2 describe-network-interfaces \
	--filters "Name=group-id,Values=$DEFAULT_SG" \
	--query 'length(NetworkInterfaces)' --output text)
echo

# The rules the zero-rule adopt would remove — so you know what is being stripped.
echo "--- Current default SG rules (these get STRIPPED on lockdown) ---"
aws ec2 describe-security-groups --group-ids "$DEFAULT_SG" \
	--query 'SecurityGroups[0].{Ingress:IpPermissions,Egress:IpPermissionsEgress}' \
	--output json
echo

# Verdict.
echo "=================================================================="
if [[ "$COUNT" == "0" ]]; then
	echo "VERDICT: SAFE — nothing is attached to the default SG."
	echo "Locking it (manage_default_security_group=true) breaks no connectivity."
else
	echo "VERDICT: REVIEW — $COUNT ENI(s) use the default SG (listed above)."
	echo "Locking strips their allow-all rules. Move them to a named SG first, or"
	echo "set manage_default_security_group=false for this VPC's module call."
fi
echo "=================================================================="
