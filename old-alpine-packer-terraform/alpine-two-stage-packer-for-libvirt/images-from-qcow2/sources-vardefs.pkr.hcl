variable "base_image_checksum" {
    type    = string
}

variable "base_image_url" {
    type    = string
}

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
    output_dir = coalesce("${var.output_dir}", "${path.root}/../output")
}

