# alpinelinux-terraform-bootstrap

## Overview

Example of bootstrapping Terrafrom and alpinelinux-userdata-terraform and
alpinelinux-vaultvars-terraform to create local (Libvirt) and remote (Vultr)
instance(s) used for provisioning other instances/clusters.

## Provisioning Hosts

* Bastion (Incoming SSH, outgoing HTTPS proxy, and NTP server for VPC) -  VPC & internet
* Vault (Vault, DHCP server for VPC, and iPXE web server for VPC) - No direct internet

## Not fully automated

As this is a platform-indepedent bootrapping exercise, we don't have automatable
secrets management until the cluster is up. In addition vault unsealing could
and should require actions by at least three separate users.

# Prerequites

* VPC (for Libvirt create an isolated network—we use the name `local-vpc`, for
Vultr create a Vultr VPC—we use name `cloud-vpc1`)

