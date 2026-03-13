#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <customer_shortname> <admin_password> <hostname>"
  exit 1
fi

customershortname="$1"
encodedpass="$2"
adminpass=$(echo "$encodedpass" | base64 -d)

hostname="$3"

echo "[1.1] Seedinging new controller: $hostname..."

cz-seed \
  --dhcp-ipv4 eth0 \
  --appliance-name "${customershortname}-controller" \
  --profile-hostname "$hostname" \
  --hostname "$hostname" \
  --admin-hostname $hostname \
  --admin-password "$adminpass" > /home/cz/seed.json

  echo "Seeding completed successfully."
