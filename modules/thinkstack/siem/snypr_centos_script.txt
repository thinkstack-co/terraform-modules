#!/bin/bash
mkfs -t xfs /dev/nvme1n1
yum update -y
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
yum install -y wget
sudo wget -O setup.sh https://concord.centrastage.net/csm/profile/downloadLinuxAgent/e5f9a55f-eacb-48a3-88e9-ec5aa58d17ff
chmod +x setup.sh
sh setup.sh
adduser securonix
usermod -aG wheel securonix
mkdir /Securonix
mount /dev/nvme1n1 /Securonix
chown securonix:securonix /Securonix
cp /etc/fstab /etc/fstab.orig
echo /dev/nvme1n1 /Securonix xfs defaults,nofail 0 2 >> /etc/fstab
mkdir /Securonix/scripts
chown securonix:securonix /Securonix/scripts
echo "find /Securonix/Ingester/import/in* -mtime +7 -exec rm {} \;" >> /Securonix/scripts/syslog_cleanup.sh
chown securonix:securonix /Securonix/scripts/*
chmod +x /Securonix/scripts/syslog_cleanup.sh
crontab -u securonix -l > ~/temp_cron && echo "0 * * * * /Securonix/scripts/syslog_cleanup.sh" >> ~/temp_cron && crontab -u securonix ~/temp_cron && rm ~/temp_cron
