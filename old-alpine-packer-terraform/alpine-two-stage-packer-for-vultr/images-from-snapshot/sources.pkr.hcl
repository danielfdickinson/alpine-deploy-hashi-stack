packer {
  required_plugins {
    qemu = {
      version = ">= v2.4.5"
      source  = "github.com/vultr/vultr"
    }
  }
}

source "vultr" "cloud-init-alpine-image" {
  api_key = "${var.vultr_api_key}"
  enable_ipv6 = var.enable_ipv6
  plan_id = "${var.plan_id}"
  region_id = "${var.region_id}"
  snapshot_id = "${var.base_snapshot_id}"
  state_timeout = "10m"
  ssh_password = "${var.ssh_password}"
  ssh_timeout = "${var.ssh_wait_timeout}"
  ssh_username = "root"
}

