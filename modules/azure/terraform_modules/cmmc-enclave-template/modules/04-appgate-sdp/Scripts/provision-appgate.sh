#!/bin/bash

set -euo pipefail

# Ensure correct number of arguments
if [ "$#" -ne 7 ]; then
  echo "Usage: $0 <customershortname> <adminpass> <fqdn> <privateip> <gatewayfqdn> <tenantid> <audienceclientid>"
  exit 1
fi

# Parameters
customershortname="$1"
adminpass="$2"
encodedpass=$(printf "%s" "$adminpass" | base64)
fqdn="$3"
privateip="$4"
gatewayfqdn="$5"
tenantid="$6"
audienceclientid="$7"

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
echo "Controller: $fqdn ($privateip)"
echo "Gateway: $gatewayfqdn"
echo "Logging to: $logfile"

echo "[1/8] Seeding controller..."
ssh -i ./ctl.pem -o StrictHostKeyChecking=no cz@"$fqdn" bash -s -- "$customershortname" "$encodedpass" "$fqdn" < ./seed-controller.sh

echo "Checking for controller health..."

max_wait=180
interval=5
elapsed=0

while true; do
  status=$(ssh -i ./ctl.pem -o StrictHostKeyChecking=no cz@"$fqdn" "sudo cz-config status | jq -r .roles.controller.status" 2>/dev/null || echo "unavailable")

  if [[ "$status" == "healthy" ]]; then
    echo "Controller is healthy."
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

echo "[2/8] Registering gateway via controller API..."
ssh -i ./ctl.pem -o StrictHostKeyChecking=no cz@"$fqdn" bash -s -- "$customershortname" "$encodedpass" "$privateip" "$gatewayfqdn" "$fqdn" < ./seed-gateway.sh

echo "[3/8] Transferring gateway seed file..."
scp -i ./ctl.pem -o StrictHostKeyChecking=no cz@"$fqdn":/tmp/gw-seed.json ./gw-seed.json
scp -i ./gw.pem -o StrictHostKeyChecking=no ./gw-seed.json cz@"$gatewayfqdn":/home/cz/seed.json
rm -f ./gw-seed.json

echo "Waiting for gateway to activate..."

max_wait=180
interval=5
elapsed=0

while true; do
  status=$(ssh -i ./gw.pem -o StrictHostKeyChecking=no cz@"$gatewayfqdn" "sudo cz-config status | jq -r .state" 2>/dev/null || echo "unavailable")

  if [[ "$status" == "appliance_ready" ]]; then
    echo "Gateway is ready."
    break
  fi

  if (( elapsed >= max_wait )); then
    echo "Gateway did not reach appliance_ready within $max_wait seconds."
    exit 1
  fi

  echo "Gateway status: $status (waiting...)"
  sleep $interval
  ((elapsed += interval))
done

echo "[4/8] Enabling full tunnel routing on default site..."
ssh -i ./ctl.pem -o StrictHostKeyChecking=no cz@"$fqdn" bash -s -- "$encodedpass" "$fqdn" < ./enable-full-tunnel-default-site.sh
sleep 5

echo "[5/8] Creating OIDC identity provider..."
ssh -i ./ctl.pem -o StrictHostKeyChecking=no cz@"$fqdn" bash -s -- "$encodedpass" "$fqdn" "$tenantid" "$audienceclientid" < ./create-oidc-idp.sh
sleep 5

echo "[6/8] Creating full tunnel entitlement..."
ssh -i ./ctl.pem -o StrictHostKeyChecking=no cz@"$fqdn" bash -s -- "$encodedpass" "$fqdn" < ./create-full-tunnel-entitlement.sh
sleep 5

echo "[7/8] Creating policy for full tunnel entitlement..."
ssh -i ./ctl.pem -o StrictHostKeyChecking=no cz@"$fqdn" bash -s -- "$encodedpass" "$fqdn" < ./create-tunnel-policy.sh
sleep 5

echo "[8/8] Creating client profile..."
ssh -i ./ctl.pem -o StrictHostKeyChecking=no cz@"$fqdn" bash -s -- "$encodedpass" "$fqdn" < ./create-client-profile.sh

echo "All steps completed successfully."
