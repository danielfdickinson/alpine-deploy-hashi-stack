
source "qemu" "cloud-init-alpine-image" {
    accelerator = "kvm"
    boot_wait = "5s"
    disk_compression = "true"
    disk_image = true
    disk_interface = "virtio"
    disk_size = "${var.disk_size}"
    format = "qcow2"
    headless = "${var.headless}"
    iso_checksum = "${var.base_image_checksum}"
    iso_target_extension = "qcow2"
    iso_url = "${var.base_image_url}"
    output_directory = "${local.output_dir}/${var.image_full_version}"
    shutdown_command = "${var.shutdown_command}"
    ssh_password = "${var.ssh_password}"
    ssh_timeout = "${var.ssh_wait_timeout}"
    ssh_username = "root"
}

