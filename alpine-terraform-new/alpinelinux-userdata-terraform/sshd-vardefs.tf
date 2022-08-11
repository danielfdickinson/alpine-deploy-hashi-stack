
variable "ssh_port" {
  type     = number
  nullable = false
}

variable "ssh_password_auth" {
  type     = bool
  default  = false
  nullable = false
}

variable "ssh_deletekeys" {
  type     = bool
  default  = true
  nullable = false
}

variable "ssh_genkeytypes" {
  type     = list(string)
  default  = ["rsa", "ed25519"]
  nullable = false
}

variable "sshd_is_bastion" {
  type    = bool
  default = false
}

locals {
  sshd_port_runcmds = [
    ["service", "sshd", "stop"],
    ["sed", "-i", "-e", "s/Port .*/Port ${var.ssh_port}/g", "/etc/ssh/sshd_config"],
    ["service", "sshd", "start"]
  ]
  sshd_bastion_runcmds = var.sshd_is_bastion ? [
    ["service", "sshd", "stop"],
    ["sed", "-i", "-e", "s/.*AllowTcpForwarding.*no.*/AllowTcpForwarding yes/g", "/etc/ssh/sshd_config"],
    ["service", "sshd", "start"]
  ] : []
  sshd_runcmds = concat(local.sshd_port_runcmds, local.sshd_bastion_runcmds)
}
