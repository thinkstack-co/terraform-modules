#!/bin/bash

# Usage: ./create-oidc-idp.sh <admin_password> <controller_dns_or_ip> <tenant_id> <audience_client_id>
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <admin_password> <controller_dns_or_ip> <tenant_id> <audience_client_id>"
  exit 1
fi

encodedpass="$1"
adminpass=$(echo "$encodedpass" | base64 -d)
ctlhost="$2"
tenantid="$3"
audience="$4"

DEVICE_ID_FILE="./appgate-device-id.txt"

if [ -f "$DEVICE_ID_FILE" ]; then
  deviceid=$(cat "$DEVICE_ID_FILE")
else
  deviceid=$(cat /proc/sys/kernel/random/uuid)
  echo "$deviceid" > "$DEVICE_ID_FILE"
fi

echo "[4.1] Logging into Appgate controller..."

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

echo "[4.2] Retrieving IP Pool ID for 'default pool v4..."

ippools=$(curl -s --insecure -X GET "https://$ctlhost:8443/admin/ip-pools" \
  -H "Authorization: Bearer $token" \
  -H "Accept: application/vnd.appgate.peer-v19+json")

ippool=$(echo "$ippools" | jq -r '.data[] | select(.name == "default pool v4") | .id')

if [ -z "$ippool" ]; then
  echo "'default pool v4' IP pool not found."
  exit 1
fi

echo "Found IP Pool ID: $ippool"

echo "[4.3] Constructing Identity Provider payload..."

issuer_url="https://login.microsoftonline.us/$tenantid/v2.0"

idp_payload=$(cat <<EOF
{
  "name": "OIDC",
  "notes": "",
  "type": "Oidc",
  "deviceLimitPerUser": 100,
  "ipPoolV4": "$ippool",
  "dnsServers": [],
  "dnsSearchDomains": [],
  "blockLocalDnsRequests": false,
  "enforceWindowsNetworkProfileAsDomain": false,
  "claimMappings": [
    {
      "attributeName": "groups",
      "claimName": "idp_groups",
      "list": true,
      "encrypt": false
    },
    {
      "attributeName": "sub",
      "claimName": "userId",
      "list": false,
      "encrypt": false
    },
    {
      "attributeName": "preferred_username",
      "claimName": "username",
      "list": false,
      "encrypt": false
    },
    {
      "attributeName": "given_name",
      "claimName": "firstName",
      "list": false,
      "encrypt": false
    },
    {
      "attributeName": "family_name",
      "claimName": "lastName",
      "list": false,
      "encrypt": false
    },
    {
      "attributeName": "email",
      "claimName": "emails",
      "list": true,
      "encrypt": false
    }
  ],
  "inactivityTimeoutMinutes": 720,
  "networkInactivityTimeoutEnabled": false,
  "google": {
    "enabled": false,
    "refreshToken": false
  },
  "issuer": "$issuer_url",
  "audience": "$audience",
  "scope": "openid profile email offline_access"
}
EOF
)

echo "[4.4] Creating Identity Provider..."

curl -s --insecure -X POST "https://$ctlhost:8443/admin/identity-providers" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.appgate.peer-v19+json" \
  -d "$idp_payload" | jq .

echo "Identity Provider created."
