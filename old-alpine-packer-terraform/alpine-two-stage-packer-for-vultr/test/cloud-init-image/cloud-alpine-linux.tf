terraform {
  required_providers {
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
  type     = string
  nullable = false
}

variable "image_version" {
  type     = string
  nullable = false
}

variable "image_full_version" {
  type     = string
  nullable = false
}

provider "vultr" {
  rate_limit  = 700
  retry_limit = 3
}

resource "random_id" "alpine-qcow2" {
  byte_length = 16

  keepers = {
    image_name         = "${var.image_name}"
    image_full_version = "${var.image_full_version}"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

data "vultr_snapshot" "alpine_snapshot" {
  filter {
    name   = "description"
    values = ["${var.image_name}-${var.image_full_version}"]
  }
}

resource "vultr_instance" "instance_alpine" {
  hostname    = "${var.image_name}-test-${var.image_version}"
  plan        = "vhp-1c-1gb-amd"
  region      = "yto"
  snapshot_id = data.vultr_snapshot.alpine_snapshot.id

  user_data       = data.template_file.user_data.rendered
  backups         = "disabled"
  enable_ipv6     = false
  ddos_protection = false

  connection {

    type = "ssh"
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

