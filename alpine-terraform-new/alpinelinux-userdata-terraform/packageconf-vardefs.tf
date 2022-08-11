# Package and additional configuration provisioning

variable "alpine_repo" {
  type = object({
    base_url          = string
    community_enabled = bool
    testing_enabled   = bool
    version           = string
  })
  nullable = true
}

variable "packages" {
  type     = list(string)
  nullable = true
}


variable "apk_preserve_repos" {
  type     = bool
  default  = true
  nullable = true
}

variable "package_update" {
  type    = bool
  default = true
}

variable "package_upgrade" {
  type    = bool
  default = true
}
