variable "write_content_files" {
  type = list(object({
    path        = string
    encoding    = string
    content     = string
    owner       = string
    permissions = string
  }))
  sensitive = true
  nullable  = true
}

variable "write_source_files" {
  type = list(object({
    path        = string
    encoding    = string
    owner       = string
    permissions = string
    source      = string
  }))
  sensitive = true
  nullable  = true
}

variable "runcmds" {
  type      = list(list(string))
  sensitive = true
  nullable  = true
}

variable "bootcmds" {
  type      = list(list(string))
  sensitive = true
  nullable  = false
}

variable "locale" {
  type    = string
  default = "C.UTF-8"
}

variable "mounts" {
  type     = list(list(string))
  nullable = true
}

variable "parts_to_grow" {
  type     = list(string)
  default  = ["/"]
  nullable = false
}


variable "disk_setup" {
  type = map(object({
    table_type = string
    layout     = list(any)
    overwrite  = bool
  }))
  nullable = true
}

variable "fs_setup" {
  type = list(object({
    device     = string
    filesystem = string
    overwrite  = bool
  }))
  nullable = true
}

