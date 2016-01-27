#!/usr/bin/env bash
cat > /etc/yum.repos.d/mantl-rpm.repo <<EOF
[mantl-rpm]
name=mantl-rpm
baseurl=https://dl.bintray.com/asteris/mantl-rpm
gpgcheck=0
enabled=1
EOF

# install base packages
yum install -y epel-release
yum install -y jq

# make mantl metadata
mkdir /etc/mantl
date > /etc/mantl/cloud-init-completed
