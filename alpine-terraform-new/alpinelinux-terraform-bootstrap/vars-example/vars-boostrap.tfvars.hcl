
alpine_repo = {
    base_url = "https://mirror.csclub.uwaterloo.ca/alpine/"
    community_enabled = true
    testing_enabled = false
    version = "v3.16"
}

admin_group = "alpine"
admin_username = "alpine"
admin_user_ssh_pubkeys = [
    "ssh-ed25519 a-real-key user@host"
]

bastion_ssh_port = "22"
vault_ssh_port = "22"

libvirt_bastion_private_network = "local-vpc"
libvirt_vault_private_network = "local-vpc"
libvirt_bastion_public_network_bridge = "br0"

bastion_packages = ["squid"]
vault_packages = ["vault","dhcpd","lighttpd"]

fallback_admin_hashed_password = "x"
libvirt_vault_hostname_short = "vault01"
vultr_vault_hostname_short = "vault01"
libvirt_vault_fqdn = "vault01.internal.example.com"
vultr_vault_fqdn = "vault01.internal.example.net"

locale = "en_CA.UTF-8"
vault_server_certificate_role = "pviate-server"
vault_client_certificate_role = "private-client"

vault_root_ca_cert = <<EOT
-----BEGIN CERTIFICATE-----
an actual certificate
-----END CERTIFICATE-----
EOT

libvirt_vault_vpc_ipv4_address = "10.30.28.22"
vultr_vault_vpc_ipv4_address = "10.30.28.20"
libvirt_bastion_ntp_chrony_allow_subet = "10.30.28.0/20"
vultr_bastion_ntp_chrony_allow_subet = "10.30.28.0/20"

