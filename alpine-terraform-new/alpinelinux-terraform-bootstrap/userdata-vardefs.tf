
variable "libvirt_vault_parts_to_grow" {
  type     = list(string)
  default  = ["/"]
  nullable = true
}

variable "vault_disk_setup" {
  type = map(object({
    table_type = string
    layout     = list(any)
    overwrite  = bool
  }))
  default = {
    "/dev/vdb" = {
      table_type = "mbr"
      layout     = [100]
      overwrite  = false
    }
  }
  nullable = true
}

variable "vault_fs_setup" {
  type = list(object({
    device     = string
    filesystem = string
    overwrite  = bool
  }))
  default = [{
    device     = "/dev/vdb1"
    filesystem = "ext4"
    overwrite  = false
  }]
  nullable = true
}

variable "vault_mounts" {
  type = list(list(string))
  default = [
    ["/dev/vdb1", "/var/lib/vault", "ext4", "rw,relatime", "0", "1"]
  ]
  nullable = true
}

variable "libvirt_bastion_manage_resolv_conf" {
  type    = bool
  default = false
}

variable "libvirt_bastion_resolv_conf" {
  type = object({
    nameservers   = list(string)
    searchdomains = list(string)
    domain        = string
  })
  nullable = true
}

variable "libvirt_vault_manage_resolv_conf" {
  type    = bool
  default = false
}

variable "libvirt_vault_resolv_conf" {
  type = object({
    nameservers   = list(string)
    searchdomains = list(string)
    domain        = string
  })
  nullable = true
}

variable "libvirt_bastion_ntp_servers" {
  type     = list(string)
  nullable = false
}

variable "vultr_bastion_ntp_servers" {
  type     = list(string)
  nullable = false
}

variable "libvirt_vault_ntp_servers" {
  type     = list(string)
  nullable = false
}

variable "vultr_vault_ntp_servers" {
  type     = list(string)
  nullable = false
}

variable "bastion_ntp_client" {
  type    = string
  default = "ntp"
}

variable "bastion_ntp_enabled" {
  type    = bool
  default = true
}

variable "libvirt_bastion_ntp_chrony_allow_subnet" {
  type     = string
  nullable = true
}

variable "libvirt_bastion_ntp_chrony_bindaddress" {
  type     = string
  nullable = true
}

variable "libvirt_bastion_tinyproxy_allow_subnet" {
  type     = string
  nullable = false
}

variable "vault_ntp_client" {
  type    = string
  default = "ntp"
}

variable "vault_ntp_enabled" {
  type    = bool
  default = true
}

variable "libvirt_bastion_ntp_pools" {
  type     = list(string)
  nullable = false
}

variable "libvirt_vault_ntp_pools" {
  type     = list(string)
  nullable = false
}

variable "vultr_bastion_ntp_pools" {
  type     = list(string)
  nullable = false
}

variable "vultr_vault_ntp_pools" {
  type     = list(string)
  nullable = false
}

variable "alpine_repo" {
  type = object({
    base_url          = string
    community_enabled = bool
    testing_enabled   = bool
    version           = string
  })
  nullable = true
}

variable "apk_preserve_repos" {
  type     = bool
  nullable = true
}

variable "admin_group" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "fallback_admin_hashed_password" {
  type = string
}

variable "vault_root_ca_cert" {
  type = string
}

variable "admin_user_ssh_pubkeys" {
  type = list(string)
}

variable "bastion_packages" {
  type     = list(string)
  nullable = true
}

variable "vault_packages" {
  type     = list(string)
  nullable = true
}

variable "libvirt_bastion_runcmds" {
  type     = list(list(string))
  nullable = false
}

variable "libvirt_vault_runcmds" {
  type     = list(list(string))
  nullable = false
}

variable "vultr_bastion_runcmds" {
  type     = list(list(string))
  nullable = false
}

variable "vultr_vault_runcmds" {
  type     = list(list(string))
  nullable = false
}

variable "libvirt_bastion_bootcmds" {
  type     = list(list(string))
  nullable = false
}

variable "libvirt_vault_bootcmds" {
  type     = list(list(string))
  nullable = false
}

variable "vultr_bastion_bootcmds" {
  type     = list(list(string))
  nullable = false
}

variable "vultr_vault_bootcmds" {
  type     = list(list(string))
  nullable = false
}

variable "libvirt_bastion_write_content_files" {
  type = list(object({
    path        = string
    encoding    = string
    content     = string
    owner       = string
    permissions = string
  }))
  sensitive = true
  nullable  = false
}

variable "vultr_bastion_write_content_files" {
  type = list(object({
    path        = string
    encoding    = string
    content     = string
    owner       = string
    permissions = string
  }))
  sensitive = true
  nullable  = false
}

variable "libvirt_vault_write_content_files" {
  type = list(object({
    path        = string
    encoding    = string
    content     = string
    owner       = string
    permissions = string
  }))
  sensitive = true
  nullable  = false
}

variable "vultr_vault_write_content_files" {
  type = list(object({
    path        = string
    encoding    = string
    content     = string
    owner       = string
    permissions = string
  }))
  sensitive = true
  nullable  = false
}

variable "libvirt_vault_hostname_short" {
  type = string
}

variable "vultr_vault_hostname_short" {
  type = string
}

variable "libvirt_vault_fqdn" {
  type = string
}

variable "vultr_vault_fqdn" {
  type = string
}

variable "vault_port" {
  type    = number
  default = 8200
}

variable "locale" {
  type = string
}

variable "vault_server_certificate_role" {
  type = string
}

variable "vault_client_certificate_role" {
  type = string
}

locals {
  libvirt_bastion_write_files = [
    {
      path = "/etc/unbound/unbound.conf"
      content = base64gzip(templatefile("${path.module}/templates/unbound.conf.tmpl", {
        dns_interface_address = var.libvirt_bastion_vpc_ipv4_address
        local_domain_name     = var.libvirt_vault_domain
      }))
      encoding    = "gz+b64"
      owner       = "root:root"
      permissions = "0644"
    },
    {
      path        = "/etc/periodic/daily/unbound-anchor.sh"
      content     = base64gzip(file("${path.module}/files/unbound-anchor.sh"))
      encoding    = "gz+b64"
      owner       = "root:root"
      permissions = "0755"
    },
    {
      path = "/etc/resolv.conf.default"
      content = base64gzip(<<-EOT
            search local-vpc.danielfdickinson.ca internal.danielfdickinson.ca
            domain internal.danielfdickinson.ca
            nameserver 127.0.0.1
            EOT
      )
      encoding    = "gz+b64"
      owner       = "root:root"
      permissions = "0644"
    },
    {
      path = "/etc/local.d/default-resolv-conf.start"
      content = base64gzip(<<-EOT
            #!/bin/sh

            /bin/ln -sf /etc/resolv.conf.default /etc/resolv.conf
            EOT
      )
      encoding    = "gz+b64"
      owner       = "root:root"
      permissions = "0755"
      }, {
      path = "/etc/tinyproxy/tinyproxy.conf"
      content = base64gzip(templatefile("${path.module}/templates/tinyproxy.conf.tmpl", {
        vpc_ipv4_address = var.libvirt_bastion_vpc_ipv4_address
        allow_subnet     = var.libvirt_bastion_tinyproxy_allow_subnet
      }))
      encoding    = "gz+b64"
      owner       = "root:root"
      permissions = "0644"
    }
  ]
  libvirt_bastion_runcmds = [
    ["sleep", "20"],
    ["mkdir", "-p", "/etc/unbound/dnssec-root"],
    ["chown", "root:unbound", "/etc/unbound/dnssec-root"],
    ["chmod", "0770", "/etc/unbound/dnssec-root"],
    ["/etc/periodic/daily/unbound-anchor.sh"],
    ["rc-update", "add", "unbound", "default"],
    ["service", "unbound", "restart"],
    ["rc-update", "add", "local", "default"],
    ["/etc/local.d/default-resolv-conf.start"],
    ["rc-update", "add", "tinyproxy", "default"],
    ["service", "tinyproxy", "restart"],
  ]
  libvirt_vault_bootcmds = [
    ["setup-proxy", "http://${var.libvirt_bastion_vpc_ipv4_address}:8888"],
    ["sh", "-c", "echo '#!/bin/sh\n. /etc/profile.d/proxy.sh\nexec /sbin/apk.real \"$@\"' >/sbin/apk.wrapper"],
    ["chmod", "0755", "/sbin/apk.wrapper"],
    ["mv", "/sbin/apk", "/sbin/apk.real"],
    ["mv", "/sbin/apk.wrapper", "/sbin/apk"]
  ]
  libvirt_vault_runcmds = [
    ["apk", "update"],
    ["apk", "upgrade"],
    concat(["apk", "add"], var.vault_packages)
  ]
}

