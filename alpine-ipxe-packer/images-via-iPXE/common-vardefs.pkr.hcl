
variable "base_image" {
    type = bool
    default = false
}

variable "image_name" {
    type = string
}

variable "image_type_version" {
    type = string
}

variable "alpine_release_version" {
    type = string
}

variable "alpine_patch_version" {
    type = string
}

variable "apk_repo_bases" {
    type = list(string)
    default = [ "https://dl-cdn.alpinelinux.org/alpine/", "http://dl-cdn.alpinelinux.org/alpine/" ]
}

variable "image_packages" {
    type = list(string)
    default = []
}

variable "extra_files_common" {
    type = string
    default = "common"
}

variable "extra_files_dir" {
    type = string
    default = ""
}

locals {
    # "timestamp" template function replacement
    timestamp = regex_replace(timestamp(), "[- TZ:]", "")
    image_full_name = "${var.image_name}_${var.image_type_version}-${var.alpine_release_version}.${var.alpine_patch_version}"
    image_version = "${var.image_type_version}-${var.alpine_release_version}.${var.alpine_patch_version}"
    alpine_full_version = "${var.alpine_release_version}.${var.alpine_patch_version}"
    # community repos are required for qemu-guest-agent, without which we cannot test the images
    apk_base_repos = join(" ", [for apk_base in var.apk_repo_bases: "${apk_base}v${var.alpine_release_version}/main ${apk_base}v${var.alpine_release_version}/community"])
    extra_files_dir = join("", [coalesce("${var.extra_files_dir}", "${path.root}/files"), "/${var.image_name}"])
    extra_files_common_dir = join("", [coalesce("${var.extra_files_dir}", "${path.root}/files"), "/${var.extra_files_common}"])
    image_packages = (var.base_image == true) ? "" : join(" ", concat(["cloud-init", "python3", "util-linux", "doas", "e2fsprogs-extra", "ca-certificates", "bash", "py-netifaces", "jq", "curl", "restic"], var.image_packages))
}

