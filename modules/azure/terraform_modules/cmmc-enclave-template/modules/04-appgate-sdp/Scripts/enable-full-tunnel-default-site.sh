#!/bin/bash

# Usage: ./enable-full-tunnel-default-site.sh <admin_password> <controller_dns_or_ip>
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <admin_password> <controller_dns_or_ip>"
  exit 1
fi

encodedpass="$1"
adminpass=$(echo "$encodedpass" | base64 -d)
ctlhost="$2"

DEVICE_ID_FILE="./appgate-device-id.txt"

if [ -f "$DEVICE_ID_FILE" ]; then
  deviceid=$(cat "$DEVICE_ID_FILE")
else
  deviceid=$(cat /proc/sys/kernel/random/uuid)
  echo "$deviceid" > "$DEVICE_ID_FILE"
fi

echo "[3.1] Authenticating..."

login_payload=$(cat <<EOF
{
  "providerName": "local",
  "username": "admin",
  "password": "$adminpass",
  "deviceId": "$deviceid"
}
EOF
)

response=$(curl -s --insecure -X POST "https://$ctlhost:8443/admin/login" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.appgate.peer-v19+json" \
  -d "$login_payload")

token=$(echo "$response" | jq -r '.token')

if [ -z "$token" ] || [ "$token" == "null" ]; then
  echo "Authentication failed."
  exit 1
fi

echo "Authenticated."

echo "[3.2] Fetching site ID..."

sites=$(curl -s --insecure -X GET "https://$ctlhost:8443/admin/sites" \
  -H "Authorization: Bearer $token" \
  -H "Accept: application/vnd.appgate.peer-v19+json")

site_id=$(echo "$sites" | jq -r '.data[] | select(.name == "Default Site") | .id')

if [ -z "$site_id" ]; then
  echo "Could not find 'Default Site'."
  exit 1
fi

echo "Site ID: $site_id"

echo "[3.3] Retrieving full site config..."

site_config=$(curl -s --insecure -X GET "https://$ctlhost:8443/admin/sites/$site_id" \
  -H "Authorization: Bearer $token" \
  -H "Accept: application/vnd.appgate.peer-v19+json")

echo "[3.4] Updating defaultGateway fields..."

updated_site=$(echo "$site_config" | jq '.defaultGateway = {
  enabledV4: true,
  enabledV6: true,
  excludedSubnets: []
}')

echo "[3.5] Pushing updated site config..."

curl -s --insecure -X PUT "https://$ctlhost:8443/admin/sites/$site_id" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.appgate.peer-v19+json" \
  -d "$updated_site" | jq .

echo "Site updated with full-tunnel routing (default gateway enabled)."
