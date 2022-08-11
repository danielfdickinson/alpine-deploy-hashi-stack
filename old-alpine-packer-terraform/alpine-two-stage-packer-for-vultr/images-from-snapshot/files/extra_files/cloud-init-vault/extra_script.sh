#!/bin/sh

set -e

cp /tmp/extra_files/etc/vault.hcl /etc/vault.hcl
chmod 0640 /etc/vault.hcl
chown root:vault /etc/vault.hcl

addgroup -S vaultcert

mkdir /etc/vault-renew
chmod 750 /etc/vault-renew
chgrp vaultcert /etc/vault-renew
