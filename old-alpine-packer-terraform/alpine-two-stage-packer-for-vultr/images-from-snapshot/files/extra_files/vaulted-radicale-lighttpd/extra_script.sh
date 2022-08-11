#!/bin/sh

set -e

cp /tmp/extra_files/etc/radicale/radicale_config.ini /etc/radicale/radicale_config.ini
chmod 0640 /etc/radicale/radicale_config.ini
chgrp radicale /etc/radicale/radicale_config.ini

cp /tmp/extra_files/etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf
chmod 0644 /etc/lighttpd/lighttpd.conf

addgroup -S vaultcert

mkdir /etc/vault-renew
chmod 750 /etc/vault-renew
chgrp vaultcert /etc/vault-renew
