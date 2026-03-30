#!/bin/bash

if [ "$#" -ne 5 ]; then
  echo "Usage: $0 <customer_shortname> <admin_password> <ctl_private_ip> <gateway_dns_name> <controller_fqdn>"
  exit 1
fi

customershortname="$1"
encodedpass="$2"
adminpass=$(echo "$encodedpass" | base64 -d)

ctlprivateip="$3"
gatewaydnsname="$4"
controllerfqdn="$5"

DEVICE_ID_FILE="./appgate-device-id.txt"

if [ -f "$DEVICE_ID_FILE" ]; then
  deviceid=$(cat "$DEVICE_ID_FILE")
else
  deviceid=$(cat /proc/sys/kernel/random/uuid)
  echo "$deviceid" > "$DEVICE_ID_FILE"
fi

echo "[2.1] Logging in to Appgate Controller at $ctlprivateip..."

read -r -d '' json_payload <<EOF
{
  "providerName": "local",
  "username": "admin",
  "password": "$adminpass",
  "deviceId": "$deviceid"
}
EOF

response=$(curl --silent --insecure --location --request POST "https://$ctlprivateip:8443/admin/login" \
--header "Content-Type: application/json" \
--header "Accept: application/vnd.appgate.peer-v19+json" \
--data "$json_payload")

token=$(echo "$response" | jq -r '.token')

if [ "$token" == "null" ] || [ -z "$token" ]; then
  echo "Failed to authenticate. Check admin password or controller IP."
  exit 1
fi

echo "Logged in. Token retrieved."

echo "[2.2] Getting site ID..."

sites=$(curl --silent --insecure --location --request GET "https://$ctlprivateip:8443/admin/sites" \
--header "Content-Type: application/json" \
--header "Accept: application/vnd.appgate.peer-v19+json" \
--header "Authorization: Bearer $token")

siteid=$(echo "$sites" | jq -r '.data[0].id')

if [ -z "$siteid" ] || [ "$siteid" == "null" ]; then
  echo "Failed to retrieve site ID."
  exit 1
fi

echo "Site ID: $siteid"

echo "[2.3] Registering new gateway: $customershortname-gateway..."

read -r -d '' json_payload <<EOF
{
  "name": "$customershortname-gateway",
  "notes": "",
  "hostname": "$gatewaydnsname",
  "site": "$siteid",
  "clientInterface": {
    "proxyProtocol": false,
    "hostname": "$gatewaydnsname",
    "httpsPort": 443,
    "dtlsPort": 443,
    "allowSources": [
      {
        "address": "0.0.0.0",
        "netmask": 0
      },
      {
        "address": "::",
        "netmask": 0
      }
    ]
  },
  "networking": {
    "hosts": [{"hostname": "$controllerfqdn", "address": "$ctlprivateip"}],
    "nics": [
      {
        "enabled": true,
        "name": "eth0",
        "ipv4": {
          "dhcp": {
            "enabled": true,
            "dns": true,
            "routers": true,
            "ntp": false,
            "mtu": false
          },
          "static": []
        },
        "ipv6": {
          "dhcp": {
            "enabled": false,
            "dns": true,
            "routers": true,
            "ntp": false,
            "mtu": false
          },
          "static": []
        }
      }
    ],
    "dnsServers": [],
    "dnsDomains": [],
    "routes": []
  },
  "ntp": {
    "servers": [
      { "hostname": "0.ubuntu.pool.ntp.org" },
      { "hostname": "1.ubuntu.pool.ntp.org" },
      { "hostname": "2.ubuntu.pool.ntp.org" },
      { "hostname": "3.ubuntu.pool.ntp.org" }
    ]
  },
  "sshServer": {
    "enabled": true,
    "port": 22,
    "allowSources": [
      { "address": "0.0.0.0", "netmask": 0 },
      { "address": "::", "netmask": 0 }
    ],
    "passwordAuthentication": true
  },
  "gateway": {
    "enabled": true,
    "suspended": false,
    "vpn": {
      "weight": 100,
      "allowDestinations": [
        {
          "address": "0.0.0.0",
          "netmask": 0,
          "nic": "eth0"
        }
      ]
    }
  }
}
EOF

gw=$(curl --silent --insecure --location --request POST "https://$ctlprivateip:8443/admin/appliances" \
--header "Content-Type: application/json" \
--header "Accept: application/vnd.appgate.peer-v19+json" \
--header "Authorization: Bearer $token" \
--data "$json_payload")

gwid=$(echo "$gw" | jq -r '.id')

if [ -z "$gwid" ] || [ "$gwid" == "null" ]; then
  echo "Failed to register gateway."
  exit 1
fi

echo "Gateway registered. Appliance ID: $gwid"

echo "[2.4] Exporting seed file to temporary location..."

tmpfile="/tmp/gw-seed.json.tmp"
finalfile="/tmp/gw-seed.json"

seed_payload='{
  "provideCloudSSHKey": true,
  "allowCustomization": false,
  "validityDays": 1
}'

curl --silent --insecure --location --request POST "https://$ctlprivateip:8443/admin/appliances/$gwid/export" \
--header "Content-Type: application/json" \
--header "Accept: application/vnd.appgate.peer-v19+json" \
--header "Authorization: Bearer $token" \
--data "$seed_payload" > "$tmpfile"

echo "[2.5] Verifying export success..."

if [ ! -s "$tmpfile" ]; then
  echo "Seed file export failed or empty."
  exit 1
fi

echo "Seed file export succeeded."

echo "[2.6] Moving completed seed file into place..."
mv "$tmpfile" "$finalfile"
echo "Moved to $finalfile"

echo "[2.7] Waiting briefly to ensure Appgate reads the file cleanly..."
sleep 1

echo "[2.8] Gateway seeding process completed successfully."
