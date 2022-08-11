
variable "vault_fqdn" {
  type     = string
  nullable = false
}

variable "vault_hostname_short" {
  type     = string
  nullable = false
}

variable "vault_ip" {
  type     = string
  nullable = false
}

variable "vault_port" {
  type     = number
  nullable = false
}

variable "vault_server_certificate_role" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "vault_client_certificate_role" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "vault_renew_services_to_restart" {
  type     = list(string)
  default  = []
  nullable = false
}

variable "vault_exclude_ip_sans" {
  type     = bool
  default  = false
  nullable = false
}

variable "vault_cert_renew_wrapper_gz_b64" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "vault_client_cert_bundle_pem" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "vault_root_ca_cert" {
  type      = string
  sensitive = true
}

locals {
  vault_base_runcmds = [
    ["/usr/sbin/update-ca-certificates"],
    local.vault_runcmd_unwrap_machine_token,
    ["/etc/periodic/daily/renew-system-certs.sh"],
    ["/etc/periodic/daily/renew-machine-token.sh"]
  ]
  vault_ip_runcmds = (var.vault_ip != "" && var.vault_fqdn != "" && var.vault_hostname_short != "") ? [
    ["sed", "-i", "-e", "$a\\${var.vault_ip} ${var.vault_fqdn} ${var.vault_hostname_short}", "/etc/hosts"]
  ] : []
}
