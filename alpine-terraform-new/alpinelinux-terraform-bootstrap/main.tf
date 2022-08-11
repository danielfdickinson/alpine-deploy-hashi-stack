terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt",
      version = "~> 0.6.14"
    }

    #        vultr = {
    #            source = "vultr/vultr",
    #            version = "~> 2.11.3"
    #        }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.1"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

#provider "vultr" {
#    rate_limit = 700
#    retry_limit = 3
#}


module "libvirt_vault_vaultvars" {
  source                          = "../alpinelinux-vaultvars-terraform"
  vault_root_ca_cert              = var.vault_root_ca_cert
  vault_hostname_short            = var.libvirt_vault_hostname_short
  vault_fqdn                      = var.libvirt_vault_fqdn
  vault_port                      = var.vault_port
  vault_server_certificate_role   = var.vault_server_certificate_role
  vault_client_certificate_role   = var.vault_client_certificate_role
  vault_client_cert_bundle_pem    = ""
  vault_cert_renew_wrapper_gz_b64 = ""
  vault_ip                        = var.libvirt_vault_vpc_ipv4_address
}

module "libvirt_bastion_userdata" {
  source                       = "../alpinelinux-userdata-terraform"
  image_name                   = var.image_name
  image_full_version           = local.image_version
  instance_name                = var.libvirt_bastion_instance_name
  instance_hyphen              = var.libvirt_bastion_instance_hyphen
  instance_code                = var.libvirt_bastion_instance_code
  domain                       = var.libvirt_bastion_domain
  disk_setup                   = null
  fs_setup                     = null
  mounts                       = null
  alpine_repo                  = var.alpine_repo
  apk_preserve_repos           = var.apk_preserve_repos
  admin_group                  = var.admin_group
  admin_username               = var.admin_username
  fallback_admin_hashed_passwd = var.fallback_admin_hashed_password
  ssh_port                     = var.bastion_ssh_port
  sshd_is_bastion              = true
  admin_user_ssh_pubkeys       = var.admin_user_ssh_pubkeys
  bootcmds                     = var.libvirt_bastion_bootcmds
  runcmds                      = concat(module.libvirt_vault_vaultvars.vault_runcmds, local.libvirt_bastion_runcmds, var.libvirt_bastion_runcmds)
  write_content_files          = concat(module.libvirt_vault_vaultvars.vault_write_content_files, local.libvirt_bastion_write_files, var.libvirt_bastion_write_content_files)
  write_source_files           = []
  locale                       = var.locale
  ntp_pools                    = var.libvirt_bastion_ntp_pools
  ntp_servers                  = var.libvirt_bastion_ntp_servers
  ntp_chrony_allow_subnet      = var.libvirt_bastion_ntp_chrony_allow_subnet
  ntp_chrony_bindaddress       = var.libvirt_bastion_vpc_ipv4_address
  packages                     = var.bastion_packages
  ntp_client                   = var.bastion_ntp_client
  manage_resolv_conf           = false
  resolv_conf                  = null
}

#module "vultr_vault_vaultvars" {
#    source = "../alpinelinux-vaultvars-terraform"
#    vault_root_ca_cert = var.vault_root_ca_cert
#    vault_hostname_short = var.vult_vault_hostname_short
#    vault_fqdn = var.vultr_vault_fqdn
#    vault_port = var.vault_port
#    vault_server_certificate_role = var.vault_server_certificate_role
#    vault_client_certificate_role = var.vault_client_certificate_role
#    vault_client_cert_bundle_pem = null
#    vault_cert_renew_wrapper_gz_b64 = null
#    vault_ip = var.vultr_vault_ip
#}

#module "vultr_bastion_userdata" {
#    source = "../alpinelinux-userdata-terraform"
#    image_name = var.image_name
#    image_full_version = local.image_version
#    instance_name = var.vultr_bastion_instance_name
#    instance_hyphen = var.vultr_bastion_instance_hypen
#    instance_code = var.vultr_bastion_instance_code
#    domain = var.vultr_bastion_domain
#    disk_setup = null
#    fs_setup = null
#    mounts = null
#    alpine_repo = var.alpine_repo
#    admin_group = var.admin_group
#    bootcmds = var.vultr_bastion_bootcmds
#    runcmds = concat(module.vultr_vault_vaultvars.vault_runcmds, var.vultr_bastion_runcmds)
#    write_files = concat(module.vultr_vault_vaultvars.vault_write_files, var.vultr_bastion_write_files)
#    locale = var.locale
#    ntp_pools = var.vultr_bastion_ntp_pools
#    ntp_servers = var.vultr_bastion_ntp_servers
#    fallback_admin_hashed_passwd = var.fallback_admin_hashed_password
#    ntp_chrony_allow_subnet = var.vultr_bastion_ntp_chrony_allow_subnet
#    ssh_port = var.bastion_ssh_port
#    sshd_is_bastion = true
#    admin_username = var.admin_username
#    packages = var.bastion_packages
#}

module "libvirt_vault_userdata" {
  source                       = "../alpinelinux-userdata-terraform"
  image_name                   = var.image_name
  image_full_version           = local.image_version
  instance_name                = var.libvirt_vault_instance_name
  instance_hyphen              = var.libvirt_vault_instance_hyphen
  instance_code                = var.libvirt_vault_instance_code
  domain                       = var.libvirt_vault_domain
  parts_to_grow                = var.libvirt_vault_parts_to_grow
  disk_setup                   = var.vault_disk_setup
  fs_setup                     = var.vault_fs_setup
  mounts                       = var.vault_mounts
  alpine_repo                  = var.alpine_repo
  apk_preserve_repos           = var.apk_preserve_repos
  package_update               = false
  package_upgrade              = false
  packages                     = []
  admin_group                  = var.admin_group
  admin_username               = var.admin_username
  fallback_admin_hashed_passwd = var.fallback_admin_hashed_password
  ssh_port                     = var.vault_ssh_port
  admin_user_ssh_pubkeys       = var.admin_user_ssh_pubkeys
  bootcmds                     = concat(local.libvirt_vault_bootcmds, var.libvirt_vault_bootcmds)
  runcmds                      = concat(local.libvirt_vault_runcmds, var.libvirt_vault_runcmds)
  write_content_files          = var.libvirt_vault_write_content_files
  write_source_files           = []
  locale                       = var.locale
  ntp_pools                    = var.libvirt_vault_ntp_pools
  ntp_servers                  = var.libvirt_vault_ntp_servers
  ntp_chrony_allow_subnet      = null
  ntp_chrony_bindaddress       = null
  manage_resolv_conf           = var.libvirt_vault_manage_resolv_conf
  resolv_conf                  = var.libvirt_vault_resolv_conf
}

#module "vultr_vault_userdata" {
#    source = "../alpinelinux-userdata-terraform"
#    image_name = var.image_name
#    image_full_version = local.image_version
#    instance_name = var.vultr_vault_instance_name
#    instance_code = var.vultr_vault_instance_code
#    domain = var.vultr_vault_domain
#    disk_setup = null
#    fs_setup = null
#    mounts = null
#    alpine_repo = var.alpine_repo
#    admin_group = var.admin_group
#    admin_username = var.admin_username
#    fallback_admin_hashed_passwd = var.fallback_admin_hashed_password
#    ssh_port = var.bastion_ssh_port
#    admin_user_ssh_pubkeys = var.admin_user_ssh_pubkeys
#    bootcmds = concat(local.vultr_vault_bootcmds, var.vultr_vault_bootcmds)
#    runcmds = var.vultr_vault_runcmds
#    write_files = var.vultr_vault_write_files
#    locale = var.locale
#    ntp_pools = var.vultr_vault_ntp_pools
#    ntp_servers = var.vultr_vault_ntp_servers
#    ntp_chrony_allow_subnet = null
#    packages = var.vault_packages
#}

resource "random_id" "alpine-bastion-os-volume" {
  byte_length = 16

  keepers = {
    image_name           = "${local.image_full_name}"
    instance_volume_name = "${local.bastion_os_volume_name}"
  }
}

resource "random_id" "alpine-vault-os-volume" {
  byte_length = 16

  keepers = {
    image_name           = "${local.image_full_name}"
    instance_volume_name = "${local.vault_os_volume_name}"
  }
}

resource "libvirt_volume" "alpine-bastion-os-volume" {
  name             = "${local.bastion_os_volume_name}_${random_id.alpine-bastion-os-volume.hex}"
  format           = "qcow2"
  base_volume_name = local.image_full_name
  size             = var.libvirt_bastion_os_size
}

resource "libvirt_volume" "alpine-vault-os-volume" {
  name             = "${local.vault_os_volume_name}_${random_id.alpine-vault-os-volume.hex}"
  format           = "qcow2"
  base_volume_name = local.image_full_name
  size             = var.libvirt_vault_os_size
}

resource "libvirt_volume" "alpine-vault-data-volume" {
  name   = local.vault_data_volume_name
  format = "qcow2"
  size   = var.libvirt_vault_data_size

  lifecycle {
    prevent_destroy = false
  }
}

locals {
  bastion_metadata = {
    instance-id = "iid-${local.bastion_instance_name}-${var.image_name}"
    hostname : local.bastion_instance_name
    network-interfaces = "auto eth0\n    iface eth0 inet static\n    address ${var.libvirt_bastion_vpc_ipv4_cidraddress}\nauto eth1\n    iface eth1 inet dhcp\n"
  }
  vault_metadata = {
    instance-id = "iid-${local.vault_instance_name}-${var.image_name}"
    hostname : local.vault_instance_name
    network-interfaces = "auto eth0\n    iface eth0 inet static\n    address ${var.libvirt_vault_vpc_ipv4_cidraddress}\n"
  }
}

resource "random_id" "alpine-bastion-instance" {
  byte_length = 16

  keepers = {
    meta_data          = yamlencode(local.bastion_metadata)
    user_data          = module.libvirt_bastion_userdata.userdata
    host_code          = "${var.libvirt_bastion_instance_code}"
    image_full_version = "${local.bastion_instance_name}"
  }
}

resource "random_id" "alpine-vault-instance" {
  byte_length = 16

  keepers = {
    meta_data          = yamlencode(local.vault_metadata)
    user_data          = module.libvirt_vault_userdata.userdata
    host_code          = "${var.libvirt_vault_instance_code}"
    image_full_version = "${local.vault_instance_name}"
  }
}

resource "libvirt_cloudinit_disk" "alpine-bastion-instance" {
  name      = "${local.bastion_cloudinit_volume_name}_${random_id.alpine-bastion-instance.hex}.iso"
  meta_data = yamlencode(local.bastion_metadata)
  user_data = module.libvirt_bastion_userdata.userdata

  lifecycle {
    create_before_destroy = true
  }
}

resource "libvirt_cloudinit_disk" "alpine-vault-instance" {
  name      = "${local.vault_cloudinit_volume_name}_${random_id.alpine-vault-instance.hex}.iso"
  meta_data = yamlencode(local.vault_metadata)
  user_data = module.libvirt_vault_userdata.userdata

  lifecycle {
    create_before_destroy = true
  }
}

resource "libvirt_domain" "alpine_bastion_instance" {
  name   = local.bastion_instance_name
  memory = var.libvirt_bastion_memory
  vcpu   = var.libvirt_bastion_num_vcpu

  cloudinit = libvirt_cloudinit_disk.alpine-bastion-instance.id

  disk {
    volume_id = libvirt_volume.alpine-bastion-os-volume.id
  }

  network_interface {
    hostname       = local.bastion_instance_name
    network_name   = var.libvirt_bastion_private_network
    wait_for_lease = false
  }

  network_interface {
    hostname       = local.bastion_instance_name
    mac            = var.libvirt_bastion_main_mac
    bridge         = var.libvirt_bastion_public_network_bridge
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
      host  = self.network_interface.1.addresses.0
      port  = var.bastion_ssh_port
      # FIXME: Check if we can only use
      # `host = self.network_interface.0.addresses.0` when using DHCP
    }

    inline = [
      "cloud-init status --wait --long",
      "if [ \"$(cloud-init status)\" != \"status: done\" ]; then exit 1; fi"
    ]
  }
}

#data "vultr_snapshot" "alpine_snapshot" {
#    filter {
#        name = "description"
#        values = ["${var.image_name}-${var.image_full_version}"]
#    }
#}

#resource "vultr_instance" "bastion_alpine_instance" {
#    hostname = "${local.instance_hostname_short}"
#    plan = "${var.plan_id}"
#    region = "${var.region_id}"
#    snapshot_id = data.vultr_snapshot.alpine_snapshot.id#
#
#    user_data = module.vultr_userdata.userdata
#    backups = "enabled"
#    backups_schedule {
#        type = "daily_alt_odd"
#    }
#    enable_ipv6 = true
#    ddos_protection = false
#
#    # Verify cloud-init completed successfully before declaring success
#    provisioner "remote-exec" {
#        connection {
#            type = "ssh"
#            user = var.admin_username
#            agent = true
#            host = self.main_ip
#            port = var.ssh_port
#        }
#
#        inline = [
#            "cloud-init status --wait --long",
#            "if [ \"$(cloud-init status)\" != \"status: done\" ]; then exit 1; fi"
#        ]
#    }
#}

resource "libvirt_domain" "alpine_vault_instance" {
  name   = local.vault_instance_name
  memory = var.libvirt_vault_memory
  vcpu   = var.libvirt_vault_num_vcpu

  cloudinit = libvirt_cloudinit_disk.alpine-vault-instance.id

  disk {
    volume_id = libvirt_volume.alpine-vault-os-volume.id
  }

  disk {
    volume_id = libvirt_volume.alpine-vault-data-volume.id
  }

  network_interface {
    hostname       = local.vault_instance_name
    network_name   = var.libvirt_vault_private_network
    wait_for_lease = false
  }

  qemu_agent = true

  video {
    type = "virtio"
  }

  # Verify cloud-init completed successfully before declaring success
  provisioner "remote-exec" {
    connection {
      type         = "ssh"
      user         = var.admin_username
      agent        = true
      port         = var.vault_ssh_port
      host         = var.libvirt_vault_vpc_ipv4_address
      bastion_user = var.admin_username
      bastion_host = libvirt_domain.alpine_bastion_instance.network_interface.1.addresses.0
      bastion_port = var.bastion_ssh_port
    }

    inline = [
      "cloud-init status --wait --long",
      "if [ \"$(cloud-init status)\" != \"status: done\" ]; then exit 1; fi"
    ]
  }
}

