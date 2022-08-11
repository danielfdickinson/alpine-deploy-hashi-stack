
locals {
    common_boot_command = [
        "<wait10>",
        "<enter><wait10>root<enter><wait10>",
        "ifconfig eth0 up && udhcpc -i eth0<enter><wait10>",
        "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/answers<enter><wait>",
        "setup-alpine -f answers<enter><wait10>",
        "alpine<enter><wait>",
        "alpine<enter>",
        "<wait30s>",
        "y<enter>",
        "<wait30s>",
        "rc-service sshd stop<enter>",
        "mount /dev/vda3 /mnt<enter>",
        "echo 'PermitRootLogin yes' >> /mnt/etc/ssh/sshd_config<enter>",
        "umount /mnt<enter>",
        "reboot<enter>"
    ]
}

source "qemu" "clean-alpine-image" {
    accelerator      = "kvm"
    boot_command     = local.common_boot_command
    boot_wait        = "5s"
    disk_compression = "true"
    disk_interface   = "virtio"
    disk_size        = "${var.disk_size}"
    format           = "qcow2"
    headless         = "${var.headless}"
    http_content     = {
        "/answers" = templatefile("http/answers", {
            apk_repos = local.apk_base_repos
        })
    }
    iso_checksum     = "${var.iso_checksum}"
    iso_url          = "${local.iso_file_url}"
    output_directory = "${local.output_dir}/${var.instance}_${var.instance_version}_${var.alpine_full_version}"
    shutdown_command = "${var.shutdown_command}"
    ssh_password     = "${var.ssh_password}"
    ssh_timeout      = "${var.ssh_wait_timeout}"
    ssh_username     = "root"
}

source "qemu" "cloud-init-alpine-image" {
    accelerator      = "kvm"
    boot_command     = local.common_boot_command
    boot_wait        = "5s"
    disk_compression = "true"
    disk_interface   = "virtio"
    disk_size        = "${var.disk_size}"
    format           = "qcow2"
    headless         = "${var.headless}"
    http_content     = {
        "/answers" = templatefile("http/answers", {
            apk_repos = local.apk_base_repos
        })
    }
    iso_checksum     = "${var.iso_checksum}"
    iso_url          = "${local.iso_file_url}"
    output_directory = "${local.output_dir}/${var.instance}_${var.instance_version}_${var.alpine_full_version}"
    shutdown_command = "${var.shutdown_command}"
    ssh_password     = "${var.ssh_password}"
    ssh_timeout      = "${var.ssh_wait_timeout}"
    ssh_username     = "root"
}

