terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt",
      version = "~> 0.6.14"
    }

    vultr = {
      source  = "vultr/vultr",
      version = "~> 2.11.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.1"
    }
  }
}

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

variable "ssh_port" {
  type    = number
  default = 566
}

variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

variable "libvirt_instance_bridge" {
  type    = string
  default = "virbr0"
}

variable "libvirt_num_vcpu" {
  type    = number
  default = 1
}

variable "libvirt_memory" {
  type    = number
  default = 256
}

variable "libvirt_image_size" {
  type    = number
  default = 2147483648
}

variable "libvirt_pool" {
  type    = string
  default = "default"
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

locals {
  image_full_name     = "${var.image_name}_${var.image_type_version}-${var.alpine_release_version}.${var.alpine_patch_version}"
  image_version       = "${var.image_type_version}-${var.alpine_release_version}.${var.alpine_patch_version}"
  alpine_full_version = "${var.alpine_release_version}.${var.alpine_patch_version}"
}

resource "random_id" "alpine-image" {
  byte_length = 16

  keepers = {
    image_name      = "${var.image_name}"
    image_full_name = "${local.image_full_name}"
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

resource "libvirt_volume" "alpine-image" {
  name             = "${var.image_name}-test_${random_id.alpine-image.hex}.qcow2"
  format           = "qcow2"
  base_volume_name = local.image_full_name
  size             = var.libvirt_image_size
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "random_id" "alpine-instance" {
  byte_length = 16

  keepers = {
    user_data_id = data.template_file.user_data.id
  }
}

resource "libvirt_cloudinit_disk" "alpine-test" {
  name      = "${local.image_full_name}-test_${random_id.alpine-instance.hex}.iso"
  user_data = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "libvirt_domain" "domain-alpine" {
  name   = "${local.image_full_name}-test-instance"
  memory = var.libvirt_memory
  vcpu   = var.libvirt_num_vcpu

  cpu {
    mode = "host-model"
  }

  disk {
    volume_id = libvirt_volume.alpine-image.id
  }

  cloudinit = libvirt_cloudinit_disk.alpine-test.id

  network_interface {
    hostname       = var.image_name
    wait_for_lease = true
    bridge         = var.libvirt_instance_bridge
  }

  qemu_agent = true

  video {
    type = "virtio"
  }

  connection {

    type = "ssh"
    port = var.ssh_port
    # This is only for the the test instance, and will be destroyed
    user     = "alpine"
    password = "alpine-test"
    # Requires use of DHCP; otherwise we must pass in the static IP address
    host = self.network_interface.0.addresses.0
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait --long",
      "if [ \"$(cloud-init status)\" != \"status: done\" ]; then exit 1; fi",
      #TODO: Allow adding per-instance tests here
      "echo 'Sucessful boot!'"
    ]
  }
}

provider "vultr" {
  rate_limit  = 700
  retry_limit = 3
}

data "vultr_snapshot" "alpine_snapshot" {
  filter {
    name   = "description"
    values = ["${local.image_full_name}"]
  }
}

resource "vultr_instance" "instance_alpine" {
  hostname    = "${var.image_name}-test-instance"
  label       = "${local.image_full_name}-test-instance"
  plan        = var.vultr_plan_id
  region      = var.vultr_region_id
  snapshot_id = data.vultr_snapshot.alpine_snapshot.id

  backups         = "disabled"
  enable_ipv6     = var.vultr_enable_ipv6
  ddos_protection = false

  user_data = data.template_file.user_data.rendered

  connection {
    type = "ssh"
    port = var.ssh_port
    # This is only for the the test instance, and will be destroyed
    user     = "alpine"
    password = "alpine-test"
    # Requires use of DHCP; otherwise we must pass in the static IP address
    host = self.main_ip
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait --long",
      "if [ \"$(cloud-init status)\" != \"status: done\" ]; then exit 1; fi",
      #TODO: Allow adding per-instance tests here
      "echo 'Sucessful boot!'"
    ]
  }
}

