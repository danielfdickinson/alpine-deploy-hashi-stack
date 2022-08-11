#!/bin/sh

set -e

mkdir -p /etc/cloud/templates
chmod 0644 /tmp/extra_files/common/etc/cloud/templates/*
cp -a /tmp/extra_files/common/etc/cloud/templates/* /etc/cloud/templates/

# Avoid non-existent serial console spamming the syslog
sed -i -e 's/^ttyS0::respawn/#ttyS0::respawn/g' /etc/inittab
