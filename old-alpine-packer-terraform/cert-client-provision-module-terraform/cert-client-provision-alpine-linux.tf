terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt",
      version = "~> 0.6.14"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.2.0"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
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
  template = templatefile("${path.module}/cloud_init.cfg.tmpl", {
    renew_certs_sh = base64gzip(templatefile("${path.module}/renew-certs.sh", {
      vault_host                    = var.vault_fqdn
      vault_port                    = var.vault_port
      vault_short_hostname          = var.vault_hostname_short
      vault_server_certificate_role = var.vault_server_certificate_role
      vault_client_certificate_role = var.vault_client_certificate_role
      exclude_ip_sans               = var.vault_exclude_ip_sans
      cert_restart_services         = var.vault_renew_services_to_restart
    }))
    renew_machine_token_sh = base64gzip(templatefile("${path.module}/renew-machine-token.sh", {
      vault_host           = var.vault_fqdn
      vault_port           = var.vault_port
      vault_short_hostname = var.vault_hostname_short
    }))
    unwrap_machine_token_sh = base64gzip(templatefile("${path.module}/unwrap-machine-token.sh", {
      vault_host = var.vault_fqdn
      vault_port = var.vault_port
    }))
    cert_renew_token_wrapper_base64     = base64gzip(file(var.vault_renew_wrapper))
    provisioning_client_cert_bundle_pem = base64gzip(file(var.vault_client_cert_bundle_pem))
    private_root_ca_cert                = base64gzip(file(var.vault_root_ca_cert))
    instance_domain                     = var.instance_domain
    instance_hostname_short             = var.instance_hostname_short
    instance_fqdn                       = var.instance_fqdn
    admin_name                          = var.admin_name
    admin_group                         = var.admin_group
  })
}

data "template_file" "meta_data" {
  template = templatefile("${path.module}/cloud_init_meta_data.tmpl", {
    instance_hostname_short = var.instance_hostname_short
    instance_full_version   = var.image_full_version
    instance_extra_version  = var.instance_extra_version
    instance_ip_address     = var.instance_ip_address
    instance_netmask        = var.instance_netmask
    instance_gateway        = var.instance_gateway
  })
}

resource "random_id" "alpinelinux-instance" {
  byte_length = 16

  keepers = {
    user_data_id           = data.template_file.user_data.id
    meta_data_id           = data.template_file.meta_data.id
    instance_name          = var.image_name
    instance_hosttag       = var.instance_hosttag
    instance_extra_version = var.instance_extra_version
    image_full_version     = var.image_full_version
  }
}

resource "libvirt_cloudinit_disk" "alpinelinux-test" {
  name      = "${var.image_name}${var.instance_hosttag}-${var.image_full_version}-${instance_extra_version}_${random_id.alpinelinux-instance.hex}.iso"
  user_data = data.template_file.user_data.rendered
  meta_data = data.template_file.meta_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "libvirt_domain" "domain-alpine" {
  name   = "${var.image_name}${var.instance_hosttag}_${var.image_full_version}"
  memory = var.instance_memory
  vcpu   = var.instance_vcpu

  cloudinit = libvirt_cloudinit_disk.alpinelinux-test.id

  disk {
    volume_id = libvirt_volume.alpine-qcow2.id
  }

  network_interface {
    hostname       = var.instance_hostname_short
    wait_for_lease = true
    bridge         = var.instance_bridge
  }

  qemu_agent = true

  video {
    type = "virtio"
  }
}

