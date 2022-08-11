variable "image_full_version" {
  type     = string
  nullable = false
}

variable "image_extra_version" {
  type     = string
  nullable = false
}

variable "image_name" {
  type     = string
  nullable = false
}

variable "image_base_image_dir" {
  type     = string
  nullable = false
}

variable "host_tag" {
  type     = string
  nullable = false
}

variable "instance_memory" {
  type    = number
  default = 512
}

variable "image_data_volume_size" {
  type     = number
  nullable = false
}

variable "image_os_volume_size" {
  type     = number
  nullable = false
}

variable "instance_cpus" {
  type    = number
  default = 1
}

variable "libvirt_uri" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "network_bridge" {
  type     = string
  nullable = false
  default  = "virbr0"
}

locals {
  # "timestamp" template function replacement
  timestamp               = replace(timestamp(), "/[- TZ:]/", "")
  os_volume_name          = "${var.image_name}-${var.host_tag}-qcow2"
  data_volume_name        = "${var.image_name}-${var.host_tag}-data-qcow2"
  cloudinit_volume_name   = "${var.image_name}-${var.host_tag}-cloudinit"
  image_domain_name       = "cloud-alpinelinux-${var.image_name}-${var.host_tag}"
  instance_fqdn           = "${var.image_name}-${var.host_tag}.${var.domain}"
  instance_hostname_short = "${var.image_name}-${var.host_tag}"
}

