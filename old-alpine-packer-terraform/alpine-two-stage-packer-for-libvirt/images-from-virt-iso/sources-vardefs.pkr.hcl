variable "cpus" {
    type    = number
}

variable "disk_size" {
    type    = number
}

variable "headless" {
    type    = bool
    default = false
}

variable "iso_checksum" {
    type    = string
}

variable "iso_file_scheme" {
    type    = string
    default = "https"
}

variable "iso_file_host" {
    type    = string
    default = "dl-cdn.alpinelinux.org"
}

variable "iso_file_base_dir" {
    type    = string
    default = "alpine"
}

variable "iso_file_arch" {
    type    = string
    default = "x86_64"
}

variable "iso_file_type" {
    type    = string
    default = "iso"
}

variable "memory" {
    type    = number
}

variable "shutdown_command" {
    type    = string
    default = "poweroff"
}

variable "ssh_password" {
    type    = string
}

variable "ssh_wait_timeout" {
    type    = string
}

variable "output_dir" {
    type = string
    default = ""
}

locals {
    iso_file_url = "${var.iso_file_scheme}://${var.iso_file_host}/${var.iso_file_base_dir}/v${var.alpine_base_version}/releases/${var.iso_file_arch}/alpine-virt-${var.alpine_full_version}-${var.iso_file_arch}.${var.iso_file_type}"
    output_dir = coalesce("${var.output_dir}", "${path.root}/../output")
}

