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
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

provider "vultr" {
  rate_limit  = 700
  retry_limit = 3
}

module "libvirt_vaultvars" {
  source = "../alpinelinux-vaultvars-terraform"
}

module "vultr_vaultvars" {
  source = "../alpinelinux-vaultvars-terraform"
}

module "vultr_userdata" {
  source = "../alpinelinux-userdata-terraform"
}

module "libvirt_userdata" {
  source = "../alpinelinux-userdata-terraform"
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
  source = "${var.image_base_image_dir}/${var.image_name}_${var.image_full_version}.qcow2"
}

resource "random_id" "alpine-os-qcow2" {
  byte_length = 16

  keepers = {
    instance_volume_name = "${local.os_volume_name}"
    image_full_version   = "${var.image_full_version}"
  }
}

resource "libvirt_volume" "os-volume-qcow2" {
  name           = "${local.os_volume_name}_${random_id.alpine-os-qcow2.hex}"
  format         = "qcow2"
  base_volume_id = libvirt_volume.alpine-qcow2.id
  size           = var.image_os_volume_size
}

resource "libvirt_volume" "data-volume-qcow2" {
  name   = local.data_volume_name
  format = "qcow2"
  size   = var.image_data_volume_size

  lifecycle {
    prevent_destroy = true
  }
}

data "template_file" "meta_data" {
  template = templatefile("${path.module}/userdata-templates/meta-data.tmpl", {
    instance_name      = "${var.instance_name}"
    host_tag           = "${var.host_tag}"
    image_full_version = "${var.image_full_version}-${var.image_extra_version}"
    ipv4_address       = "${var.ipv4_address}"
    ipv4_gateway       = "${var.ipv4_gateway}"
  })
}

data "template_file" "user_data" {
  template = templatefile("${path.module}/userdata-templates/user-data.tmpl", {
    admin_group                  = var.admin_group
    admin_user_ssh_pubkeys       = var.admin_user_ssh_pubkeys
    admin_username               = var.admin_username
    doas_nopass                  = var.doas_nopass
    domain                       = var.domain
    fallback_admin_hashed_passwd = var.fallback_admin_hashed_passwd
    files_to_write               = var.files_to_write
    host_tag                     = var.host_tag
    image_full_version           = "${var.image_full_version}-${var.image_extra_version}"
    instance_name                = var.instance_name
    mounts                       = var.mounts
    ntp_servers                  = var.ntp_servers
    packages                     = var.packages
    runcmds                      = var.runcmds
    write_files                  = var.write_files
    renew_certs_sh = base64gzip(templatefile("${path.module}/userdata-templates/renew-certs.sh", {
      vault_host                    = var.vault_fqdn
      vault_port                    = var.vault_port
      vault_short_hostname          = var.vault_hostname_short
      vault_server_certificate_role = var.vault_server_certificate_role
      vault_client_certificate_role = var.vault_client_certificate_role
      exclude_ip_sans               = var.vault_exclude_ip_sans
      cert_restart_services         = var.vault_renew_services_to_restart
    }))
    renew_machine_token_sh = base64gzip(templatefile("${path.module}/userdata-templates/renew-machine-token.sh", {
      vault_host           = var.vault_fqdn
      vault_port           = var.vault_port
      vault_short_hostname = var.vault_hostname_short
    }))
    unwrap_machine_token_sh = base64gzip(templatefile("${path.module}/userdata-templates/unwrap-machine-token.sh", {
      vault_host = var.vault_fqdn
      vault_port = var.vault_port
    }))
    cert_renew_token_wrapper_base64     = base64gzip(file(var.vault_cert_renew_wrapper))
    provisioning_client_cert_bundle_pem = base64gzip(file(var.vault_client_cert_bundle_pem))
    private_root_ca_cert                = base64gzip(file(var.vault_root_ca_cert))
    instance_domain                     = var.domain
    instance_hostname_short             = local.instance_hostname_short
    instance_fqdn                       = local.instance_fqdn
  })
}

resource "random_id" "alpinelinux-instance" {
  byte_length = 16

  keepers = {
    meta_data_id       = data.template_file.meta_data.id,
    user_data_id       = data.template_file.user_data.id,
    host_tag           = "${var.host_tag}"
    image_full_version = "${var.image_full_version}"
  }
}

resource "libvirt_cloudinit_disk" "alpinelinux-instance" {
  name      = "${local.cloudinit_volume_name}_${random_id.alpinelinux-instance.hex}.iso"
  meta_data = data.template_file.meta_data.rendered
  user_data = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "libvirt_domain" "image_domain" {
  name   = local.image_domain_name
  memory = var.instance_memory
  vcpu   = var.instance_cpus

  cloudinit = libvirt_cloudinit_disk.alpinelinux-instance.id

  # Alpine cloud images enable serial console use by default and spams
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

  disk {
    volume_id = libvirt_volume.os-volume-qcow2.id
  }

  disk {
    volume_id = libvirt_volume.data-volume-qcow2.id
  }

  network_interface {
    hostname       = "${var.instance_name}-${var.host_tag}"
    bridge         = var.network_bridge
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
      user  = var.admin_username
      agent = true
      host  = self.network_interface.0.addresses.0
      # FIXME: Check if we can only use `host = self.network_interface.0.addresses.0` when using DHCP
      # host = "${var.instance_name}-${var.host_tag}"
    }

    inline = [
      "cloud-init status --wait --long",
      "if [ \"$(cloud-init status)\" != \"status: done\" ]; then exit 1; fi"
    ]
  }
}

data "vultr_snapshot" "alpine_snapshot" {
  filter {
    name   = "description"
    values = ["${var.image_name}-${var.image_full_version}"]
  }
}

resource "vultr_instance" "instance_alpine" {
  hostname    = local.instance_hostname_short
  plan        = var.plan_id
  region      = var.region_id
  snapshot_id = data.vultr_snapshot.alpine_snapshot.id

  user_data = data.template_file.user_data.rendered
  backups   = "enabled"
  backups_schedule {
    type = "daily_alt_odd"
  }
  enable_ipv6     = true
  ddos_protection = false

  # Verify cloud-init completed successfully before declaring success
  provisioner "remote-exec" {
    connection {
      type  = "ssh"
      user  = var.admin_username
      agent = true
      host  = self.main_ip
      port  = var.ssh_port
    }

    inline = [
      "cloud-init status --wait --long",
      "if [ \"$(cloud-init status)\" != \"status: done\" ]; then exit 1; fi"
    ]
  }
}
