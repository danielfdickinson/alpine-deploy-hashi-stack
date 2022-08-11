variable "vultr_api_key" {
    type = string
    default = "${env("VULTR_API_KEY")}"
}

variable "ssh_username" {
    type = string
}

variable "ssh_wait_timeout" {
    type = string
}

variable "libvirt_uri" {
    type = string
    default = "qemu:///system"
}

variable "libvirt_num_vcpu" {
    type = number
    default = 1
}

variable "libvirt_memory" {
    type = number
    default = 512
}

variable "libvirt_image_size" {
    type = string
    default = "1G"
}

variable "libvirt_pool" {
    type = string
    default = "default"
}

variable "libvirt_network_type" {
    type = string
    default = "managed"
}

variable "libvirt_pxe_network" {
    type = string
    default = "pxeboot"
}

variable "libvirt_pxe_bridge" {
    type = string
    default = ""
}

variable "libvirt_pxe_mac" {
    type = string
    default = ""
}

variable "libvirt_ssh_host" {
    type = string
    default = ""
}

variable "libvirt_address_source" {
    type = string
    default = "lease"
}

variable "vultr_plan_id" {
    type = string
    default = "vc2-1c-1gb" # default to smallest instance
}

variable "vultr_region_id" {
    type = string
    default = "${env("VULTR_REGION_ID")}"
}

variable "vultr_enable_ipv6" {
    type = string
    default = "${env("VULTR_ENABLE_IPV6")}"
}

variable "vultr_ipxe_script_id" {
    type = string
    default = "${env("VULTR_IPXE_SCRIPT_ID")}"
}

