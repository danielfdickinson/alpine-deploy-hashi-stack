
variable "vultr_api_key" {
  type = string
  default = "${env("VULTR_API_KEY")}"
}

variable "plan_id" {
    type = string
}

variable "region_id" {
    type = string
}

variable "base_snapshot_id" {
    type = string
}

variable "enable_ipv6" {
    type = bool
    default = true
}

variable "ssh_password" {
    type = string
}

variable "ssh_wait_timeout" {
    type = string
}

