#!/bin/bash
set -euo pipefail

# Format and mount the data volume
DATA_DEVICE="/dev/nvme1n1"
MOUNT_POINT="/Securonix"

# Create filesystem only if one doesn't already exist (idempotent)
if ! blkid "${DATA_DEVICE}" >/dev/null 2>&1; then
	mkfs -t xfs "${DATA_DEVICE}"
fi

# Update system and install required packages
yum update -y
yum install -y wget
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Download and run setup script
SETUP_SCRIPT_URL="https://concord.centrastage.net/csm/profile/downloadLinuxAgent/e5f9a55f-eacb-48a3-88e9-ec5aa58d17ff"
SETUP_SCRIPT_PATH="/tmp/setup.sh"
wget -O "${SETUP_SCRIPT_PATH}" "${SETUP_SCRIPT_URL}"
chmod +x "${SETUP_SCRIPT_PATH}"
"${SETUP_SCRIPT_PATH}"

# Create user and set up directories
if ! id securonix >/dev/null 2>&1; then
	adduser securonix
fi
usermod -aG wheel securonix
mkdir -p "${MOUNT_POINT}"

# Mount if not already mounted
if ! mountpoint -q "${MOUNT_POINT}"; then
	mount "${DATA_DEVICE}" "${MOUNT_POINT}"
fi
chown securonix:securonix "${MOUNT_POINT}"

# Update fstab for persistent mount
cp /etc/fstab /etc/fstab.orig
if ! grep -q "^${DATA_DEVICE} ${MOUNT_POINT} " /etc/fstab; then
	echo "${DATA_DEVICE} ${MOUNT_POINT} xfs defaults,nofail 0 2" >>/etc/fstab
fi

# Set up cleanup script and cron job
mkdir -p "${MOUNT_POINT}/scripts"
cat >"${MOUNT_POINT}/scripts/syslog_cleanup.sh" <<'EOF'
#!/bin/bash
find /Securonix/Ingester/import/in* -mtime +7 -exec rm {} \;
EOF

chown securonix:securonix "${MOUNT_POINT}/scripts"/*
chmod +x "${MOUNT_POINT}/scripts/syslog_cleanup.sh"

# Add cron job for securonix user
CRON_LINE="0 * * * * /Securonix/scripts/syslog_cleanup.sh"
TMP_CRON_FILE="$(mktemp)"
crontab -u securonix -l >"${TMP_CRON_FILE}" 2>/dev/null || true
if ! grep -Fq "${CRON_LINE}" "${TMP_CRON_FILE}"; then
	echo "${CRON_LINE}" >>"${TMP_CRON_FILE}"
fi
crontab -u securonix "${TMP_CRON_FILE}"
rm -f "${TMP_CRON_FILE}"
