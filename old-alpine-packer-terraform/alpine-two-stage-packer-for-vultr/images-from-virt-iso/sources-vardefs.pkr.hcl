variable "vultr_api_key" {
    type = string
    default = "${env("VULTR_API_KEY")}"
}

variable "ssh_password" {
    type = string
}

variable "ssh_wait_timeout" {
    type = string
}

