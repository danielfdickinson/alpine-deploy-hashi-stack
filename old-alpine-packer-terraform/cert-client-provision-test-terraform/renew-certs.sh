#!/bin/sh

EXCLUDE_IP_SANS="${exclude_ip_sans}"

URL1="https://${vault_host}:${vault_port}/v1/pki/issue/${vault_server_certificate_role}"
CERT1='--cert /etc/vault-renew/client-cert-bundle.pem'

if [ "$(hostname -s)" = "${vault_short_hostname}" ]; then
    URL1="http://127.0.0.1:${vault_port}/v1/pki/issue/${vault_server_certificate_role}"
    unset CERT1
else
    URL2="https://${vault_host}:${vault_port}/v1/pki/issue/${vault_client_certificate_role}"
    CERT2="$${CERT1}"
fi

TARGET_CERT1="$(hostname -f)"
TARGET_CERT2="$(hostname -s)@$(hostname -d)"
TARGET_ALT_NAMES="$(hostname -f)"
# 'src' of default route should be our main IP address
TARGET_IP_DEFAULT_SRC="$(ip -4 route | tail -n1 | tr -s ' ' | tr -s ' ' $'\n' | tail -n1)"
# if we haven't explicitly set the IP SANS for the certificate, use the
# 'src' of the default route (should be our main ip address)
TARGET_IP_SANS="$${TARGET_IP_SANS:-$TARGET_IP_DEFAULT_SRC}"

if [ "$EXCLUDE_IP_SANS" != "true" ] && [ -n "$${TARGET_IP_SANS}" ]; then
    IP_SANS=",\"ip_sans\":\"$${TARGET_IP_SANS}\""
fi

umask 0177

echo -n "X-Vault-Token: " >/etc/vault-renew/token-header || exit 1
cat /etc/vault-renew/cert-renew-token >>/etc/vault-renew/token-header || exit 1

if [ -n "$${URL1}" ]; then
    curl -f --no-progress-meter -o /etc/vault-renew/server-cert-response.json \
        --header @/etc/vault-renew/token-header \
        --request "POST" \
        --url $URL1 \
        --data "{\"name\":\"${vault_server_certificate_role}\",\"common_name\":\"$${TARGET_CERT1}\"$${IP_SANS},\"ttl\":\"72h\"}" \
        $${CERT1} || exit 1

    jq -r .data.certificate /etc/vault-renew/server-cert-response.json >/etc/vault-renew/cert.pem || exit 1
    jq -r .data.issuing_ca /etc/vault-renew/server-cert-response.json >>/etc/vault-renew/cert.pem || exit 1
    chgrp vaultcert /etc/vault-renew/cert.pem || exit 1
    chmod 0640 /etc/vault-renew/cert.pem || exit 1
    jq -r .data.private_key /etc/vault-renew/server-cert-response.json >/etc/vault-renew/key.pem || exit 1
    chgrp vaultcert /etc/vault-renew/key.pem || exit 1
    chmod 0640 /etc/vault-renew/key.pem || exit 1
    rm -f /etc/vault-renew/server-cert-response.json || exit 1
fi

if [ -n "$${URL2}" ]; then
    curl -f -s -o /etc/vault-renew/client-cert-response.json \
        --header @/etc/vault-renew/token-header \
        --request "POST" \
        --url $URL2 \
        --data "{\"name\":\"${vault_client_certificate_role}\",\"common_name\":\"$${TARGET_CERT2}\"$${IP_SANS},\"format\":\"pem_bundle\",\"ttl\":\"72h\"}" \
        $${CERT2} || exit 1

    jq -r .data.certificate /etc/vault-renew/client-cert-response.json >/etc/vault-renew/new-client-cert-bundle.pem || exit 1
    jq -r .data.issuing_ca /etc/vault-renew/client-cert-response.json >>/etc/vault-renew/new-client-cert-bundle.pem || exit 1
        chgrp vaultcert /etc/vault-renew/new-client-cert-bundle.pem || exit 1
    chmod 0640 /etc/vault-renew/new-client-cert-bundle.pem || exit 1
    mv /etc/vault-renew/new-client-cert-bundle.pem /etc/vault-renew/client-cert-bundle.pem || exit 1
    rm -f /etc/vault-renew/client-cert-response.json || exit 1
fi

%{for cert_restart_service in cert_restart_services}
service ${cert_restart_service} reload
%{endfor}

exit 0
