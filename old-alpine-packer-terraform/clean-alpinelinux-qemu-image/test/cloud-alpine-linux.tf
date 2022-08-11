terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt",
      version = "~> 0.6.14"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.3"
    }
  }
}

variable "alpine_instance" {
  type     = string
  nullable = false
}

variable "instance_full_version" {
  type     = string
  nullable = false
}

variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

variable "instance_bridge" {
  type    = string
  default = "virbr0"
}

provider "libvirt" {
  uri = var.libvirt_uri
}

variable "output_dir" {
  type    = string
  default = ""
}

locals {
  output_dir = coalesce("${var.output_dir}", "${path.root}/../output")
}

resource "random_id" "alpine-qcow2" {
  byte_length = 16


  keepers = {
    instance              = "${var.alpine_instance}"
    instance_full_version = "${var.instance_full_version}"
  }
}

resource "libvirt_volume" "alpine-qcow2" {
  name   = "alpine_${random_id.alpine-qcow2.hex}.qcow2"
  format = "qcow2"
  source = "${local.output_dir}/${var.alpine_instance}_${var.instance_full_version}/${var.alpine_instance}_${var.instance_full_version}.qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "random_id" "alpinelinux-instance" {
  byte_length = 16

  keepers = {
    user_data_id = data.template_file.user_data.id
  }
}

resource "libvirt_cloudinit_disk" "alpinelinux-test" {
  name      = "${var.alpine_instance}_${var.instance_full_version}-test_${random_id.alpinelinux-instance.hex}.iso"
  user_data = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "libvirt_domain" "domain-alpine" {
  name   = "${var.alpine_instance}_${var.instance_full_version}-test"
  memory = "256"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.alpinelinux-test.id

  cpu {
    mode = "host-model"
  }

  disk {
    volume_id = libvirt_volume.alpine-qcow2.id
  }

  network_interface {
    hostname       = var.alpine_instance
    wait_for_lease = true
    bridge         = var.instance_bridge
  }

  qemu_agent = true

  video {
    type = "virtio"
  }


  connection {

    type = "ssh"
    # This is only for the the test instance, and will be destroyed
    user     = "alpine"
    password = "alpine-test"
    # Requires use of DHCP; otherwise we must pass in the static IP address
    host = self.network_interface.0.addresses.0
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait --long",
      "if [ \"$(cloud-init status)\" != \"status: done\" ]; then exit 1; fi"
    ]
  }
}


