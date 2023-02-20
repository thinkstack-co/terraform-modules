#!/bin/bash

set -euo pipefail

apt-get -y install python-setuptools
cd /opt/trustgrid

RANDFILE=/tmp/.rnd ansible-playbook packer.yml > /bootstrap.out
rm -rf /opt/trustgrid
cd /usr/local/trustgrid && bin/register.sh
mv /usr/local/trustgrid/tg-apt.crt /etc/apt/ssl/tg-apt.crt
chown _apt:root /etc/apt/ssl
apt-get update
curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
chmod +x ./awslogs-agent-setup.py
./awslogs-agent-setup.py -n -r ${region} -c /etc/cloudwatch.cfg
shutdown -r now