locals {
  userdata_scalars = {
    hostname                  = "${var.instance_name}${var.instance_hyphen}${var.instance_code}"
    domain                    = var.domain
    fqdn                      = "${var.instance_name}${var.instance_hyphen}${var.instance_code}.${var.domain}"
    prefer_fqdn_over_hostname = var.prefer_fqdn
    manage_resolv_conf        = var.manage_resolv_conf
    manage_etc_hosts          = var.manage_etc_hosts
    ssh_pwauth                = var.ssh_password_auth
    ssh_deletekeys            = var.ssh_deletekeys
    locale                    = var.locale
    package_update            = var.package_update
    package_upgrade           = var.package_upgrade
  }
  userdata_objects = {
    ntp = {
      ntp_client = var.ntp_client
      enabled    = var.ntp_enabled
      pools      = var.ntp_pools
      servers    = var.ntp_servers
    }
    growpart = {
      mode    = "auto"
      devices = var.parts_to_grow
    }
    disk_setup = var.disk_setup
    apk_repos = {
      preserve_repositories = var.apk_preserve_repos
      alpine_repo           = var.alpine_repo
    }
    resolv_conf = var.resolv_conf
  }
  userdata_scalar_lists = {
    ssh_genkeytypes = var.ssh_genkeytypes
    packages        = var.packages
  }
  userdata_list_lists = {
    mounts  = var.mounts
    runcmd  = concat(local.ntp_runcmds, local.sshd_runcmds, var.runcmds)
    bootcmd = var.bootcmds
  }
  userdata_object_lists = {
    users = [
      {
        name                = var.admin_username
        primary_group       = var.admin_group
        doas                = ["permit${var.doas_nopass != "" ? " " : ""}${var.doas_nopass}${var.doas_nopass != "" ? " " : ""}${var.doas_persist} ${var.admin_username} as root"]
        groups              = local.admin_user_extra_groups
        hashed_passwd       = var.fallback_admin_hashed_passwd
        lock_passwd         = false
        ssh_authorized_keys = var.admin_user_ssh_pubkeys
      },
      {
        name          = "root"
        hashed_passwd = "x"
        lock_passwd   = true
      }
    ]
    fs_setup    = var.fs_setup
    write_files = concat((length(var.write_content_files) > 0 ? var.write_content_files : []), (length(var.write_source_files) > 0 ? var.write_source_files : []))
  }
  userdata_file = templatefile("${path.module}/templates/userdata.tmpl", {
    userdata_scalars      = local.userdata_scalars,
    userdata_objects      = local.userdata_objects,
    userdata_scalar_lists = local.userdata_scalar_lists,
    userdata_list_lists   = local.userdata_list_lists,
    userdata_object_lists = local.userdata_object_lists,
  })
}
