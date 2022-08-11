variable "image_name" {
  type     = string
  nullable = false
}

variable "image_full_version" {
  type     = string
  nullable = false
}

variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

variable "instance_bridge" {
  type    = string
  default = "virbr0"
}

variable "libvirt_image_dir" {
  type     = string
  nullable = false
}

variable "instance_name" {
  type     = string
  nullable = false
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
  type     = string
  nullable = false
}

variable "vault_client_certificate_role" {
  type     = string
  nullable = false
}

variable "vault_renew_services_to_restart" {
  type    = list(string)
  default = []
}

variable "vault_exclude_ip_sans" {
  type    = boolean
  default = false
}

variable "vault_cert_renew_wrapper" {
  type     = string
  nullable = false
}

variable "vault_client_cert_bundle_pem" {
  type     = string
  nullable = false
}

variable "vault_root_ca_cert" {
  type     = string
  nullable = false
}

variable "instance_memory" {
  type     = number
  nullable = false
  default  = 512
}

variable "instance_vcpu" {
  type     = number
  nullable = false
  default  = 1
}

variable "instance_domain" {
  type     = string
  nullable = false
}

variable "instance_hosttag" {
  type     = string
  nullable = false
}

variable "instance_hostname_short" {
  type     = string
  nullable = false
}

variable "instance_fqdn" {
  type     = string
  nullable = false
}

variable "instance_extra_version" {
  type     = string
  nullable = false
}

variable "instance_ip_address" {
  type     = string
  nullable = false
}

variable "instance_netmask" {
  type     = string
  nullable = false
  default  = "255.255.255.0"
}

variable "instance_gateway" {
  type     = string
  nullable = false
}

variable "admin_name" {
  type     = string
  nullable = false
  default  = "alpine"
}

variable "admin_group" {
  type     = string
  nullable = false
  default  = "alpine"
}

