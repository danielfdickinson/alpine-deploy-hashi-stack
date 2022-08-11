
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
  type     = string
  default  = "nopass"
  nullable = false
}

variable "doas_persist" {
  type     = string
  default  = ""
  nullable = false
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

variable "admin_user_extra_groups" {
  type     = list(string)
  default  = ["adm", "sys", "wheel"]
  nullable = false
}

locals {
  admin_user_extra_groups = join(",", var.admin_user_extra_groups)
}
