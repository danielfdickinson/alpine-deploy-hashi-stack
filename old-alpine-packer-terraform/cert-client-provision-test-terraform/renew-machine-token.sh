#!/bin/sh

URL="https://${vault_host}:${vault_port}/v1/auth/token/renew-self"
CERT='--cert /etc/vault-renew/client-cert-bundle.pem'

if [ "$(hostname -s)" = "${vault_short_hostname}" ]; then
    URL="http://127.0.0.1:${vault_port}/v1/auth/token/renew-self"
    unset CERT
fi

umask 0177
echo -n "X-Vault-Token: " >/etc/vault-renew/token-header || exit 1
cat /etc/vault-renew/cert-renew-token >>/etc/vault-renew/token-header || exit 1

curl -f -o /dev/null --no-progress-meter \
    --header @/etc/vault-renew/token-header \
    --request "POST" \
    --url "$URL" \
    $${CERT} || exit 1

exit 0
