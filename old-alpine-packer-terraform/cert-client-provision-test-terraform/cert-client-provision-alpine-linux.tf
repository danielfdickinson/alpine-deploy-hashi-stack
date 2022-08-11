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
  default  = "vaulted-base-alpine"
}

variable "image_full_version" {
  type     = string
  nullable = false
  default  = "0.1.2-3.15.4"
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

variable "libvirt_image_dir" {
  type    = string
  default = "/home/daniel/LibvirtBaseImages"
}

variable "instance_name" {
  type     = string
  nullable = false
}

resource "random_id" "alpine-qcow2" {
  byte_length = 16

  keepers = {
    image_name         = var.image_name
    instance_name      = var.instance_name
    image_full_version = var.image_full_version
  }
}

resource "libvirt_volume" "alpine-qcow2" {
  name   = "${var.instance_name}_${var.image_name}_${random_id.alpine-qcow2.hex}.qcow2"
  format = "qcow2"
  source = "${var.libvirt_image_dir}/${var.image_name}_${var.image_full_version}.qcow2"
}

data "template_file" "user_data" {
  template = templatefile("${path.module}/cloud_init.cfg", {
    renew_certs_sh = base64gzip(templatefile("${path.module}/renew-certs.sh", {
      vault_host                    = "vault.internal.danielfdickinson.ca"
      vault_port                    = 8200
      vault_short_hostname          = "vault"
      vault_server_certificate_role = "dfd-server"
      vault_client_certificate_role = "dfd-client"
      exclude_ip_sans               = "true"
      cert_restart_services         = []
    }))
    renew_machine_token_sh = base64gzip(templatefile("${path.module}/renew-machine-token.sh", {
      vault_host           = "vault.internal.danielfdickinson.ca"
      vault_port           = 8200
      vault_short_hostname = "vault"
    }))
    unwrap_machine_token_sh = base64gzip(templatefile("${path.module}/unwrap-machine-token.sh", {
      vault_host = "vault.internal.danielfdickinson.ca"
      vault_port = 8200
    }))
    cert_renew_token_wrapper_base64     = base64gzip(file("/home/daniel/WorkDir/cert-renew-token-wrapper.b64"))
    provisioning_client_cert_bundle_pem = base64gzip(file("/home/daniel/WorkDir/provisioning-client-cert-bundle.pem"))
    private_root_ca_cert                = base64gzip(file("/home/daniel/ca-private.internal.danielfdickinson.ca.crt"))
  })
}

resource "random_id" "alpinelinux-instance" {
  byte_length = 16

  keepers = {
    user_data_id  = data.template_file.user_data.id
    instance_name = var.instance_name
  }
}

resource "libvirt_cloudinit_disk" "alpinelinux-test" {
  name      = "${var.instance_name}-${var.image_full_version}-test_${random_id.alpinelinux-instance.hex}.iso"
  user_data = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "libvirt_domain" "domain-alpine" {
  name   = "${var.instance_name}_${var.image_name}_${var.image_full_version}"
  memory = "256"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.alpinelinux-test.id

  disk {
    volume_id = libvirt_volume.alpine-qcow2.id
  }

  network_interface {
    hostname       = var.instance_name
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
    # FIXME: Verify if this requires use of DHCP and otherwise we must pass in the static IP address
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

