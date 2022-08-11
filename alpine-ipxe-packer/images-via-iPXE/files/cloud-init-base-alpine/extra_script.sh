#!/bin/sh

set -e

addgroup -S vaultcert

mkdir /etc/vault-renew
chmod 750 /etc/vault-renew
chgrp vaultcert /etc/vault-renew

