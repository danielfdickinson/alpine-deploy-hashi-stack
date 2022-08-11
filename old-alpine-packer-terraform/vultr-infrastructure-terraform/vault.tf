module "vault" {
  source                          = "git::ssh://gitea@dlgit.internal.danielfdickinson.ca/danielfdickinson/alpinelinux-vultr-terraform.git"
  ssh_port                        = 566
  region_id                       = "yto"
  plan_id                         = "vc2-1c-1gb"
  image_full_version              = "cloud-init-vault_0.1.7-3.15.4"
  image_name                      = "cloud-init-vault"
  instance_name                   = "vault"
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
  vault_renew_services_to_restart = []
  vault_server_certificate_role   = "dfd-server"
  vault_client_certificate_role   = "dfd-client"
  vault_cert_renew_wrapper        = ""
  vault_client_cert_bundle_pem    = ""
  vault_root_ca_cert              = ""
  files_to_write                  = []
  write_files = {
  }
  packages    = []
  runcmds     = []
  ntp_servers = []
  mounts      = []
}

