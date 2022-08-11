variable "image_full_version" {
  type     = string
  nullable = false
}

variable "image_name" {
  type     = string
  nullable = false
}

variable "host_tag" {
  type     = string
  nullable = false
}

variable "plan_id" {
  type     = string
  nullable = false
}

variable "region_id" {
  type     = string
  nullable = false
}

variable "ssh_port" {
  type = number
}

locals {
  # "timestamp" template function replacement
  timestamp               = replace(timestamp(), "/[- TZ:]/", "")
  image_domain_name       = "cloud-alpinelinux-${var.image_name}-${var.host_tag}"
  instance_fqdn           = "${var.image_name}-${var.host_tag}.${var.domain}"
  instance_hostname_short = "${var.instance_name}-${var.host_tag}"
}

