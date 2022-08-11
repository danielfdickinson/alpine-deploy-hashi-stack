#!/bin/sh

set -e

mkdir -p /etc/cloud/templates
chmod 0644 /tmp/extra_files/common/etc/cloud/templates/*
cp -a /tmp/extra_files/common/etc/cloud/templates/* /etc/cloud/templates/
