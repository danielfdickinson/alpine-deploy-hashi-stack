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

variable "instance_full_version" {
  type     = string
  nullable = false
}

variable "instance_extra_version" {
  type     = string
  nullable = false
}

variable "instance_name" {
  type     = string
  nullable = false
}

locals {
  # "timestamp" template function replacement
  timestamp             = replace(timestamp(), "/[- TZ:]/", "")
  os_volume_name        = "${var.instance_name}-qcow2"
  data_volume_name      = "${var.instance_name}-data-qcow2"
  cloudinit_volume_name = "${var.instance_name}-cloudinit"
  instance_domain_name  = "cloud-alpinelinux-${var.instance_name}"
}

provider "libvirt" {
  uri = "qemu+ssh://virtuser@dcloud01.internal.danielfdickinson.ca:22/system?sshauth=agent"
}

resource "random_id" "alpine-qcow2" {
  byte_length = 16

  keepers = {
    instance_name         = "${var.instance_name}"
    instance_full_version = "${var.instance_full_version}"
  }
}

resource "libvirt_volume" "alpine-qcow2" {
  name   = "alpine_${random_id.alpine-qcow2.hex}.qcow2"
  format = "qcow2"
  source = "/home/daniel/LibvirtBaseImages/${var.instance_name}_${var.instance_full_version}.qcow2"
}

resource "libvirt_volume" "os-volume-qcow2" {
  name           = local.os_volume_name
  format         = "qcow2"
  base_volume_id = libvirt_volume.alpine-qcow2.id
  size           = "8589934592"
}

resource "libvirt_volume" "data-volume-qcow2" {
  name   = local.data_volume_name
  format = "qcow2"
  size   = "8589934592"

  lifecycle {
    prevent_destroy = true
  }
}

data "template_file" "user_data" {
  template = templatefile("${path.module}/${var.instance_name}_user_data.tmpl", {
    hostname  = "${var.instance_name}"
    domain    = "internal.danielfdickinson.ca"
    timestamp = local.timestamp
    motd = base64gzip(<<EOT
${var.instance_name}.internal.danielfdickinson.ca created ${local.timestamp}

EOT
    )
  })
}

data "template_file" "meta_data" {
  template = templatefile("${path.module}/${var.instance_name}_meta_data.tmpl", {
    hostname               = "${var.instance_name}"
    instance_full_version  = var.instance_full_version
    instance_extra_version = var.instance_extra_version
  })
}

resource "random_id" "alpinelinux-instance" {
  byte_length = 16

  keepers = {
    user_data_id = data.template_file.user_data.id
    meta_data_id = data.template_file.meta_data.id
  }
}

resource "libvirt_cloudinit_disk" "alpinelinux-instance" {
  name      = "${local.cloudinit_volume_name}_${random_id.alpinelinux-instance.hex}.iso"
  user_data = data.template_file.user_data.rendered
  meta_data = data.template_file.meta_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "libvirt_domain" "instance_domain" {
  name   = local.instance_domain_name
  memory = "512"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.alpinelinux-instance.id

  # Alpine cloud images enable serial console use by default and spam
  # the logs if one is not present, so we create one.
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  cpu {
    mode = "host-model"
  }

  disk {
    volume_id = libvirt_volume.os-volume-qcow2.id
  }

  disk {
    volume_id = libvirt_volume.data-volume-qcow2.id
  }

  network_interface {
    hostname       = var.instance_name
    bridge         = "br1"
    wait_for_lease = true
  }

  qemu_agent = true

  video {
    type = "virtio"
  }

  # Verify cloud-init completed successfully before declaring success
  provisioner "remote-exec" {
    connection {
      type  = "ssh"
      user  = "aideraan"
      agent = true
      # We can only use `host = self.network_interface.0.addresses.0` when using DHCP
      host = var.instance_name
    }

    inline = [
      "cloud-init status --wait --long",
      "if [ \"$(cloud-init status)\" != \"status: done\" ]; then exit 1; fi"
    ]
  }
}

