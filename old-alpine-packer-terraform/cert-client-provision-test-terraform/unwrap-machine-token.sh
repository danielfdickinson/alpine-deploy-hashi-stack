#!/bin/sh


URL_BASE="https://${vault_host}:${vault_port}/v1/"
CERT='--cert /etc/vault-renew/client-cert-bundle.pem'


umask 0177
base64 -d /etc/vault-renew/cert-renew-token-wrapper.b64 >/etc/vault-renew/cert-renew-token-wrapper || exit 1

rm -f /etc/vault-renew/cert-renew-token-wrapper.b64

curl -o /etc/vault-renew/cert-renew-token-wrap-lookup.json --no-progress-meter \
    --request "POST" \
    --data "{\"token\":\"$(cat /etc/vault-renew/cert-renew-token-wrapper)\"}" \
    --url "$${URL_BASE}sys/wrapping/lookup" \
    $${CERT} || {
        echo "Failed to lookup cert-renew-token-wrapper" >&2
        exit 1
    }

if [ "$(jq -r .data.creation_path /etc/vault-renew/cert-renew-token-wrap-lookup.json)" != "auth/token/create" ]; then
    echo "Unexpected token wrapper creation path; investigate" >&2
    exit 1
fi

if [ "$(jq -r .warnings /etc/vault-renew/cert-renew-token-wrap-lookup.json)" != "null" ]; then
    echo "Unexpected token wrapper warnings; investigate" >&2
    echo "warnings: $(jq -r .warnings /etc/vault-renew/cert-renew-token-wrap-lookup.json)" >&2
    exit 1
fi

rm -f /etc/vault-renew/cert-renew-token-wrap-lookup.json

echo -n "X-Vault-Token: " >/etc/vault-renew/cert-renew-token-wrapper-header || exit 1
cat /etc/vault-renew/cert-renew-token-wrapper >>/etc/vault-renew/cert-renew-token-wrapper-header || exit 1
rm -f /etc/vault-renew/cert-renew-token-wrapper || exit 1

curl -f -o /etc/vault-renew/cert-renew-token-unwrap.json -s \
    --header @/etc/vault-renew/cert-renew-token-wrapper-header \
    --request "POST" \
    --url "$${URL_BASE}sys/wrapping/unwrap" \
    $${CERT} || {
        echo "Failed to unwrap cert-renew-token; investigate" &>2
        exit 1
    }


rm -f /etc/vault-renew/cert-renew-token-wrapper-header || exit 1

if [ "$(jq -r .warnings /etc/vault-renew/cert-renew-token-unwrap.json)" != "null" ]; then
    echo "Unexpected token unwrap warnings; investigate" >&2
    echo "warnings: $(jq -r .warnings /etc/vault-renew/cert-renew-token-unwrap.json)" >&2
    exit 1
fi

jq -r .auth.client_token /etc/vault-renew/cert-renew-token-unwrap.json >/etc/vault-renew/cert-renew-token || exit 1
rm -f /etc/vault-renew/cert-renew-token-unwrap.json

echo "Unwrap of machine cert-renew-token successful"

exit 0
