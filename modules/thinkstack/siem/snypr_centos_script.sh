#!/bin/bash
set -e

# Format and mount the data volume
mkfs -t xfs /dev/nvme1n1

# Update system and install required packages
yum update -y
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
yum install -y wget

# Download and run setup script
wget -O setup.sh https://concord.centrastage.net/csm/profile/downloadLinuxAgent/e5f9a55f-eacb-48a3-88e9-ec5aa58d17ff
chmod +x setup.sh
./setup.sh

# Create user and set up directories
adduser securonix
usermod -aG wheel securonix
mkdir -p /Securonix
mount /dev/nvme1n1 /Securonix
chown securonix:securonix /Securonix

# Update fstab for persistent mount
cp /etc/fstab /etc/fstab.orig
echo "/dev/nvme1n1 /Securonix xfs defaults,nofail 0 2" >> /etc/fstab

# Set up cleanup script and cron job
mkdir -p /Securonix/scripts
cat > "/Securonix/scripts/syslog_cleanup.sh" << 'EOF'
#!/bin/bash
find /Securonix/Ingester/import/in* -mtime +7 -exec rm {} \;
EOF

chown securonix:securonix /Securonix/scripts/*
chmod +x /Securonix/scripts/syslog_cleanup.sh

# Add cron job for securonix user
crontab -u securonix -l > ~/temp_cron 2>/dev/null || touch ~/temp_cron
echo "0 * * * * /Securonix/scripts/syslog_cleanup.sh" >> ~/temp_cron
crontab -u securonix ~/temp_cron
rm ~/temp_cron
