#!/bin/bash

# Usage: ./create-full-tunnel-entitlement.sh <admin_password> <controller_dns_or_ip>
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

echo "[5.1] Logging into Appgate controller..."

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

echo "[5.2] Retrieving Default Site ID..."

sites=$(curl -s --insecure -X GET "https://$ctlhost:8443/admin/sites" \
  -H "Authorization: Bearer $token" \
  -H "Accept: application/vnd.appgate.peer-v19+json")

site_id=$(echo "$sites" | jq -r '.data[] | select(.name == "Default Site") | .id')

if [ -z "$site_id" ]; then
  echo "'Default Site' not found."
  exit 1
fi

echo "Found Default Site ID: $site_id"

echo "[5.3] Generating unique action IDs..."

tcp_action_id=$(cat /proc/sys/kernel/random/uuid)
udp_action_id=$(cat /proc/sys/kernel/random/uuid)
icmp_action_id=$(cat /proc/sys/kernel/random/uuid)

echo "[5.4] Creating 'Outbound All Protocols - Full Tunnel' entitlement..."

entitlement_payload=$(cat <<EOF
{
  "name": "Outbound All Protocols - Full Tunnel",
  "notes": "Allows outbound access to all destinations and ports",
  "site": "$site_id",
  "actions": [
    {
      "type": "IpAccess",
      "action": "allow",
      "hosts": ["0.0.0.0/0"],
      "subtype": "tcp_up",
      "ports": ["1-65535"],
      "monitor": {
        "enabled": false,
        "timeout": 30
      },
      "id": "$tcp_action_id"
    },
    {
      "type": "IpAccess",
      "action": "allow",
      "hosts": ["0.0.0.0/0"],
      "subtype": "udp_up",
      "ports": ["1-65535"],
      "monitor": {
        "enabled": false,
        "timeout": 30
      },
      "id": "$udp_action_id"
    },
    {
      "type": "IpAccess",
      "action": "allow",
      "hosts": ["0.0.0.0/0"],
      "subtype": "icmp_up",
      "types": ["0-255"],
      "id": "$icmp_action_id"
    }
  ],
  "conditionLogic": "and",
  "conditions": [
    "ee7b7e6f-e904-4b4f-a5ec-b3bef040643e"
  ],
  "disabled": false
}
EOF
)

curl -s --insecure -X POST "https://$ctlhost:8443/admin/entitlements" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.appgate.peer-v19+json" \
  -d "$entitlement_payload" | jq .

echo "Entitlement creation attempt complete."
