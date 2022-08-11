variable "domain" {
  type     = string
  nullable = false
}

variable "ntp_pools" {
  type     = list(string)
  nullable = false
}

variable "ntp_servers" {
  type     = list(string)
  nullable = false
}

variable "ntp_client" {
  type     = string
  default  = "ntp"
  nullable = false
}

variable "ntp_enabled" {
  type     = bool
  default  = true
  nullable = false
}

variable "ntp_chrony_allow_subnet" {
  type     = string
  nullable = true
}

variable "ntp_chrony_bindaddress" {
  type     = string
  nullable = true
}

variable "prefer_fqdn" {
  type    = bool
  default = true
}

variable "manage_resolv_conf" {
  type    = bool
  default = false
}

variable "resolv_conf" {
  type = object({
    nameservers   = list(string)
    searchdomains = list(string)
    domain        = string
  })
  nullable = true
}

variable "manage_etc_hosts" {
  type    = bool
  default = true
}


locals {
  ntp_runcmds = (var.ntp_servers != null && var.ntp_client == "ntp") ? [
    ["sed", "-i", "-e", "s/NTPD_OPTS=\"-N .*/NTPD_OPTS=\"-N\"/g", "/etc/conf.d/ntpd"],
    ["service", "ntpd", "restart"]
    ] : var.ntp_client == "chrony" ? [
    ["sed", "-i", "-e", "$a\\allow ${var.ntp_chrony_allow_subnet}", "/etc/chrony/chrony.conf"],
    ["sed", "-i", "-e", "$a\\bindaddress ${var.ntp_chrony_bindaddress}", "/etc/chrony/chrony.conf"],
    ["rc-update", "del", "ntpd", "boot"],
    ["rc-update", "add", "chronyd", "boot"],
    ["service", "ntpd", "stop"],
    ["service", "chronyd", "restart"]
  ] : []
}

