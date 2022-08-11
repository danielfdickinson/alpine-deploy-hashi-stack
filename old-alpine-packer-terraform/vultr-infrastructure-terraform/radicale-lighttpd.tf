module "radicale-lighttpd" {
  source                          = "git::ssh://gitea@dlgit.internal.danielfdickinson.ca/danielfdickinson/alpinelinux-vultr-terraform.git"
  ssh_port                        = 566
  region_id                       = "yto"
  plan_id                         = "vc2-1c-1gb"
  image_full_version              = "vaulted-radicale-lighttpd_0.1.3-3.15.4"
  image_name                      = "vaulted-radicale-lighttpd"
  instance_name                   = "radicale-lighttpd"
  host_tag                        = "01"
  domain                          = "wildtechgarden.ca"
  admin_username                  = "aideraan"
  admin_group                     = "aideraan"
  doas_nopass                     = "nopass"
  fallback_admin_hashed_passwd    = "x"
  admin_user_ssh_pubkeys          = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPC0BIhoKortImhc3r5utlep5c7QQo4FviaO5XxssECe d-f-d@DWMD"]
  vault_fqdn                      = "vault-01.wildtechgarden.ca"
  vault_hostname_short            = "vault-01"
  vault_port                      = "8200"
  vault_server_certificate_role   = "dfd-server"
  vault_client_certificate_role   = "dfd-client"
  vault_renew_services_to_restart = []
  vault_cert_renew_wrapper        = "files/cert-renew-token-wrapper-radicale-lighttpd-01.wildtechgarden.ca.b64"
  vault_client_cert_bundle_pem    = "files/cert-client-provision-radicale-lighttpd-01@wildtechgarden.ca.pem"
  vault_root_ca_cert              = "files/ca-private.internal.danielfdickinson.ca.crt"
  files_to_write = [
    "/etc/radicale/config",
    "/etc/radicale/rights",
    "/etc/lighttpd/lighttpd.conf",
    "/etc/lighttpd/denybadbots.conf",
    "/var/www/localhost/htdocs/favicon.ico",
    "/var/www/localhost/htdocs/index.html",
    "/var/www/localhost/htdocs/robots.txt"
  ]
  write_files = {
    "/etc/radicale/config" = {
      permissions = "0640"
      owner       = "root:radicale"
      append      = false
      content     = base64gzip(file("${path.module}/files/radicale/config"))
      encoding    = "gz+b64"
      source      = ""
    }
    "/etc/radicale/rights" = {
      permissions = "0640"
      owner       = "root:radicale"
      append      = false
      content     = base64gzip(file("${path.module}/files/radicale/rights"))
      encoding    = "gz+b64"
      source      = ""
    }
    "/etc/lighttpd/lighttpd.conf" = {
      permissions = "0644"
      owner       = "root:root"
      append      = "false"
      content     = base64gzip(file("${path.module}/files/lighttpd/lighttpd.conf"))
      encoding    = "gz+b64"
      source      = ""
    }
    "/etc/lighttpd/denybadbots.conf" = {
      permissions = "0644"
      owner       = "root:root"
      append      = "false"
      content     = base64gzip(file("${path.module}/files/lighttpd/denybadbots.conf"))
      encoding    = "gz+b64"
      source      = ""
    }
    "/var/www/localhost/htdocs/favicon.ico" = {
      permissions = "0644"
      owner       = "root:root"
      append      = "false"
      content     = filebase64("${path.module}/files/lighttpd/htdocs/favicon.ico")
      encoding    = "base64"
      source      = ""
    }
    "/var/www/localhost/htdocs/index.html" = {
      permissions = "0644"
      owner       = "root:root"
      append      = "false"
      content     = base64gzip(file("${path.module}/files/lighttpd/htdocs/index.html"))
      encoding    = "gz+b64"
      source      = ""
    }
    "/var/www/localhost/htdocs/robots.txt" = {
      permissions = "0644"
      owner       = "root:root"
      append      = "false"
      content     = base64gzip(file("${path.module}/files/lighttpd/htdocs/robots.txt"))
      encoding    = "gz+b64"
      source      = ""
    }
  }
  packages = ["tmux", "py3-pip"]
  runcmds = [
    ["python3", "-m", "pip", "install", "--upgrade", "https://github.com/Unrud/RadicaleInfCloud/archive/master.tar.gz"],
    ["mkdir", "-p", "/var/lib/lighttpd/cache/compress"],
    ["chown", "-R", "lighttpd:lighttpd", "/var/lib/lighttpd/cache"]
  ]
  ntp_servers = []
  mounts      = []
}

