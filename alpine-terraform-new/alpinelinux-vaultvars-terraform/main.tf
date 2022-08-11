locals {
  cert_renew_token_wrapper_gz_b64 = var.vault_cert_renew_wrapper_gz_b64 != "" ? [{
    path        = "/etc/vault-renew/cert-renew-token-wrapper.gz.b64"
    content     = file(var.vault_cert_renew_wrapper_gz_b64)
    encoding    = "gz+b64"
    owner       = "root:root"
    permissions = "0600"
  }] : []
  provisioning_client_cert_bundle_pem = var.vault_client_cert_bundle_pem != "" ? [{
    path        = "/etc/vault-renew/client-cert-bundle.pem"
    content     = base64gzip(file(var.vault_client_cert_bundle_pem))
    encoding    = "gz+b64"
    owner       = "root:vaultcert"
    permissions = "0640"
  }] : []
  private_root_ca_cert = var.vault_root_ca_cert != "" ? [{
    path        = "/usr/local/share/ca-certificates/ca-private-internal.crt"
    content     = base64gzip(file(var.vault_root_ca_cert))
    encoding    = "gz+b64"
    owner       = "root:root"
    permissions = "0644"
  }] : []

  vault_base_write_files = [
    {
      path = "/etc/periodic/daily/renew-machine-token.sh"
      content = base64gzip(templatefile("${path.module}/userdata-templates/renew-machine-token.sh", {
        vault_host           = var.vault_fqdn
        vault_port           = var.vault_port
        vault_short_hostname = var.vault_hostname_short
      }))
      encoding    = "gz+b64"
      owner       = "root:root"
      permissions = "0755"
    },
    {
      path = "/etc/periodic/daily/renew-system-certs.sh"
      content = base64gzip(templatefile("${path.module}/userdata-templates/renew-certs.sh", {
        vault_host                    = var.vault_fqdn
        vault_port                    = var.vault_port
        vault_short_hostname          = var.vault_hostname_short
        vault_server_certificate_role = var.vault_server_certificate_role
        vault_client_certificate_role = var.vault_client_certificate_role
        exclude_ip_sans               = var.vault_exclude_ip_sans
        cert_restart_services         = var.vault_renew_services_to_restart
      }))
      encoding    = "gz+b64"
      owner       = "root:root"
      permissions = "0755"
      }, {
      path = "/root/unwrap-machine-token.sh"
      content = base64gzip(templatefile("${path.module}/userdata-templates/unwrap-machine-token.sh", {
        vault_host = var.vault_fqdn
        vault_port = var.vault_port
      }))
      encoding    = "gz+b64"
      owner       = "root:root"
      permissions = "0600"
    }
  ]
  vault_runcmd_unwrap_machine_token = var.vault_cert_renew_wrapper_gz_b64 != "" ? [
    "sh", "-c", "/root/unwrap-machine-token.sh && rm -f /root/unwrap-machine-token.sh"
  ] : []
  vault_write_files = concat(
    local.vault_base_write_files,
    local.cert_renew_token_wrapper_gz_b64,
    local.provisioning_client_cert_bundle_pem,
    local.private_root_ca_cert
  )
  vault_runcmds = concat(local.vault_base_runcmds, local.vault_ip_runcmds)
}
