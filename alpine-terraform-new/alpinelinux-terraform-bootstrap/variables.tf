variable "image_name" {
  type = string
}

variable "image_type_version" {
  type = string
}

variable "alpine_release_version" {
  type = string
}

variable "alpine_patch_version" {
  type = string
}

variable "libvirt_bastion_instance_name" {
  type = string
}

variable "libvirt_vault_instance_name" {
  type = string
}

variable "libvirt_bastion_instance_hyphen" {
  type    = string
  default = ""
}

variable "libvirt_vault_instance_hyphen" {
  type    = string
  default = ""
}

variable "libvirt_bastion_instance_code" {
  type = string
}

variable "libvirt_vault_instance_code" {
  type = string
}

variable "libvirt_bastion_domain" {
  type = string
}

variable "libvirt_vault_domain" {
  type = string
}

variable "vultr_bastion_domain" {
  type = string
}

variable "vultr_vault_domain" {
  type = string
}

variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

variable "libvirt_bastion_num_vcpu" {
  type    = number
  default = 1
}

variable "libvirt_vault_num_vcpu" {
  type    = number
  default = 1
}

variable "libvirt_bastion_memory" {
  type    = number
  default = 512
}

variable "libvirt_vault_memory" {
  type    = number
  default = 1024
}

variable "libvirt_bastion_os_size" {
  type    = number
  default = 26843545600
}

variable "libvirt_vault_os_size" {
  type    = number
  default = 8589934592
}

variable "libvirt_vault_data_size" {
  type    = number
  default = 10737418240
}

variable "libvirt_pool" {
  type    = string
  default = "default"
}

variable "libvirt_bastion_vpc_ipv4_address" {
  type = string
}

variable "libvirt_bastion_vpc_ipv4_cidraddress" {
  type = string
}

variable "libvirt_vault_vpc_ipv4_address" {
  type = string
}

variable "libvirt_vault_vpc_ipv4_cidraddress" {
  type = string
}

variable "vultr_plan_id" {
  type    = string
  default = "vc2-1c-1gb" # default to smallest instance
}

variable "vultr_region_id" {
  type = string
}

variable "vultr_enable_ipv6" {
  type    = bool
  default = false
}

variable "bastion_ssh_port" {
  type = number
}

variable "vault_ssh_port" {
  type = number
}

variable "libvirt_bastion_main_mac" {
  type = string
}

variable "libvirt_bastion_public_network_bridge" {
  type = string
}

variable "libvirt_bastion_private_network" {
  type = string
}

variable "libvirt_vault_private_network" {
  type = string
}

locals {
  image_full_name               = "${var.image_name}_${var.image_type_version}-${var.alpine_release_version}.${var.alpine_patch_version}"
  image_version                 = "${var.image_type_version}-${var.alpine_release_version}.${var.alpine_patch_version}"
  alpine_full_version           = "${var.alpine_release_version}.${var.alpine_patch_version}"
  bastion_instance_name         = "${var.libvirt_bastion_instance_name}${var.libvirt_bastion_instance_hyphen}${var.libvirt_bastion_instance_code}"
  vault_instance_name           = "${var.libvirt_vault_instance_name}${var.libvirt_vault_instance_hyphen}${var.libvirt_vault_instance_code}"
  bastion_os_volume_name        = "${local.bastion_instance_name}-os"
  vault_os_volume_name          = "${local.vault_instance_name}-os"
  vault_data_volume_name        = "${local.vault_instance_name}-data"
  bastion_cloudinit_volume_name = "${local.bastion_instance_name}-cloudinit"
  vault_cloudinit_volume_name   = "${local.vault_instance_name}-cloudinit"
}
