
variable "image_name" {
    type = string
}

variable "image_full_version" {
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

locals {
    # "timestamp" template function replacement
    timestamp = regex_replace(timestamp(), "[- TZ:]", "")
    # community repos are required for qemu-guest-agent, without which we cannot test the images
    apk_base_repos = join(" ", [for apk_base in var.apk_repo_bases: "${apk_base}v${var.alpine_base_version}/main ${apk_base}v${var.alpine_base_version}/community"])
    image_packages = join(" ", [for image_package in var.image_packages: "${image_package}"])
}

