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

variable "image_name" {
  type     = string
  nullable = false
}

variable "image_full_version" {
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
  output_dir = coalesce("${var.output_dir}", "${path.root}/../../output")
}

resource "random_id" "alpine-qcow2" {
  byte_length = 16


  keepers = {
    image_name         = "${var.image_name}"
    image_full_version = "${var.image_full_version}"
  }
}

resource "libvirt_volume" "alpine-qcow2" {
  name   = "alpine_${random_id.alpine-qcow2.hex}.qcow2"
  format = "qcow2"
  source = "${local.output_dir}/${var.image_full_version}/${var.image_full_version}.qcow2"
}

resource "libvirt_domain" "domain-alpine" {
  name   = "${var.image_full_version}-test"
  memory = "256"
  vcpu   = 1

  cpu {
    mode = "host-model"
  }

  disk {
    volume_id = libvirt_volume.alpine-qcow2.id
  }

  network_interface {
    hostname       = var.image_name
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
    user     = "root"
    password = "alpine"
    host     = self.network_interface.0.addresses.0
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Sucessful boot!'"
    ]
  }
}


