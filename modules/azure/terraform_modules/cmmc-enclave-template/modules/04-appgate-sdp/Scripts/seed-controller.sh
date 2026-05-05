#!/bin/bash

if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <customer_shortname> <admin_password> <hostname>"
	exit 1
fi

customershortname="$1"
encodedpass="$2"
adminpass=$(echo "$encodedpass" | base64 -d)

hostname="$3"

echo "[1.1] Seeding new controller: $hostname..."

sudo cz-seed \
	--dhcp-ipv4 eth0 \
	--appliance-name "${customershortname}-controller" \
	--profile-hostname "$hostname" \
	--hostname "$hostname" \
	--admin-hostname "$hostname" \
	--admin-password "$adminpass" \
	--ntp-server 91.189.91.157 \
	--ntp-server 91.189.89.198 \
	--ntp-server 91.189.94.4 \
	--ntp-server 91.189.91.156 | sudo tee /home/cz/seed.json >/dev/null

echo "Seeding completed successfully."
