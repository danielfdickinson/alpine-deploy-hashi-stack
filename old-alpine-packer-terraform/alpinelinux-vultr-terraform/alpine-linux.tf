terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr",
      version = "~> 2.11.2"
    }
  }
}

provider "vultr" {
  rate_limit  = 700
  retry_limit = 3
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
    cert_renew_token_wrapper_base64     = var.vault_cert_renew_wrapper != "" ? base64gzip(file(var.vault_cert_renew_wrapper)) : ""
    provisioning_client_cert_bundle_pem = var.vault_client_cert_bundle_pem != "" ? base64gzip(file(var.vault_client_cert_bundle_pem)) : ""
    private_root_ca_cert                = var.vault_root_ca_cert != "" ? base64gzip(file(var.vault_root_ca_cert)) : ""
    instance_domain                     = var.domain
    instance_hostname_short             = local.instance_hostname_short
    instance_fqdn                       = local.instance_fqdn
  })
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

