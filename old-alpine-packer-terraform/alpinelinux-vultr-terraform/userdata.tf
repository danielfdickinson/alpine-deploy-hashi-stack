variable "instance_name" {
  type     = string
  nullable = false
}

variable "domain" {
  type     = string
  nullable = false
}

variable "files_to_write" {
  type      = list(string)
  sensitive = true
}

variable "write_files" {
  type = map(object({
    append      = bool
    encoding    = string
    content     = any
    owner       = string
    permissions = string
    source      = any
  }))
  sensitive = true
}

variable "packages" {
  type = list(string)
}

variable "runcmds" {
  type      = list(list(string))
  sensitive = true
}

variable "ntp_servers" {
  type = list(string)
}

variable "mounts" {
  type = list(list(string))
}

variable "admin_username" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "admin_group" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "doas_nopass" {
  type = string
}

variable "fallback_admin_hashed_passwd" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "admin_user_ssh_pubkeys" {
  type      = list(string)
  nullable  = false
  sensitive = true
}

variable "vault_fqdn" {
  type     = string
  nullable = false
}

variable "vault_hostname_short" {
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
}

variable "vault_client_certificate_role" {
  type      = string
  sensitive = true
}

variable "vault_renew_services_to_restart" {
  type    = list(string)
  default = []
}

variable "vault_exclude_ip_sans" {
  type    = bool
  default = false
}

variable "vault_cert_renew_wrapper" {
  type      = string
  sensitive = true
  nullable  = true
}

variable "vault_client_cert_bundle_pem" {
  type      = string
  sensitive = true
  nullable  = true
}

variable "vault_root_ca_cert" {
  type      = string
  sensitive = true
  nullable  = true
}

