#!/bin/bash

set -euo pipefail

# Ensure correct number of arguments
if [ "$#" -ne 6 ]; then
  echo "Usage: $0 <customershortname> <adminpass> <fqdn> <privateip> <tenantid> <audienceclientid>"
  exit 1
fi

# Parameters
customershortname="$1"
adminpass="$2"
encodedpass=$(printf "%s" "$adminpass" | base64)
fqdn="$3"
privateip="$4"
tenantid="$5"
audienceclientid="$6"

# Log setup
timestamp=$(date +%Y%m%d-%H%M%S)
logfile="provision-log-$timestamp.log"
exec > >(tee -a "$logfile") 2>&1

# Check all required scripts exist
required_scripts=(
  seed-controller.sh
  seed-gateway.sh
  enable-full-tunnel-default-site.sh
  create-oidc-idp.sh
  create-full-tunnel-entitlement.sh
  create-tunnel-policy.sh
  create-client-profile.sh
)

for script in "${required_scripts[@]}"; do
  if [ ! -f "$script" ]; then
    echo "Required script missing: $script"
    exit 1
  fi
done

echo "Running from: $(hostname)"
echo "Target appliance: $fqdn ($privateip)"
echo "Logging to: $logfile"

echo "[1/7] Seeding controller..."
ssh -i ./appgate.pem cz@"$fqdn" bash -s -- "$customershortname" "$encodedpass" "$fqdn" < ./seed-controller.sh

echo "Checking for controller health..."

max_wait=180
interval=5
elapsed=0

while true; do
  status=$(ssh -i ./appgate.pem cz@"$fqdn" "sudo cz-config status | jq -r .roles.controller.status" 2>/dev/null || echo "unavailable")

  if [[ "$status" == "healthy" ]]; then
    echo "Controller is healthy. Proceeding to seed gateway..."
    break
  fi

  if (( elapsed >= max_wait )); then
    echo "Controller did not become healthy within $max_wait seconds."
    exit 1
  fi

  echo "Controller status: $status (waiting...)"
  sleep $interval
  ((elapsed += interval))
done

echo "[2/7] Seeding gateway (same appliance)..."
ssh -i ./appgate.pem cz@"$fqdn" bash -s -- "$customershortname" "$encodedpass" "$privateip" "$fqdn" < ./seed-gateway.sh
sleep 5

echo "[3/7] Enabling full tunnel routing on default site..."
ssh -i ./appgate.pem cz@"$fqdn" bash -s -- "$encodedpass" "$fqdn" < ./enable-full-tunnel-default-site.sh
sleep 5

echo "[4/7] Creating OIDC identity provider..."
ssh -i ./appgate.pem cz@"$fqdn" bash -s -- "$encodedpass" "$fqdn" "$tenantid" "$audienceclientid" < ./create-oidc-idp.sh
sleep 5

echo "[5/7] Creating full tunnel entitlement..."
ssh -i ./appgate.pem cz@"$fqdn" bash -s -- "$encodedpass" "$fqdn" < ./create-full-tunnel-entitlement.sh
sleep 5

echo "[6/7] Creating policy for full tunnel entitlement..."
ssh -i ./appgate.pem cz@"$fqdn" bash -s -- "$encodedpass" "$fqdn" < ./create-tunnel-policy.sh
sleep 5

echo "[7/7] Creating client profile..."
ssh -i ./appgate.pem cz@"$fqdn" bash -s -- "$encodedpass" "$fqdn" < ./create-client-profile.sh

echo "All steps completed successfully."
