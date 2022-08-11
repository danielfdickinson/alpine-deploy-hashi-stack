variable "alpine_base_version" {
    type = string
}

variable "alpine_full_version" {
    type = string
}

variable "instance" {
    type = string
}

variable "instance_version" {
    type = string
}

variable "apk_repo_bases" {
    type = list(string)
    default = [ "https://dl-cdn.alpinelinux.org/alpine/", "http://dl-cdn.alpinelinux.org/alpine/" ]
}

variable "instance_packages" {
    type = list(string)
}

variable "extra_files_dir" {
    type = string
    default = ""
}

variable "extra_files_common" {
    type = string
    default = "common"
}


variable "private_ca_cert" {
    type = string
    default = ""
}

locals {
    # "timestamp" template function replacement
    timestamp = regex_replace(timestamp(), "[- TZ:]", "")
    apk_base_repos = join(" ", [for apk_base in var.apk_repo_bases: "${apk_base}v${var.alpine_base_version}/main"])
    apk_community_repos_nl = join("\n", [for apk_base in var.apk_repo_bases: "${apk_base}v${var.alpine_base_version}/community"])
    instance_packages = join(" ", [for instance_package in var.instance_packages: "${instance_package}"])
    extra_files_dir = join("", [coalesce("${var.extra_files_dir}", "${path.root}/files/extra_files"), "/${var.instance}"])
    extra_files_common_dir = join("", [coalesce("${var.extra_files_dir}", "${path.root}/files/extra_files"), "/${var.extra_files_common}"])
}

