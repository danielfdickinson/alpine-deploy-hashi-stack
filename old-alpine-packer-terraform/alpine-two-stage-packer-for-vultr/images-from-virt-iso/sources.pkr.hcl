
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

source "vultr" "base-alpine-image" {
    api_key = "${var.vultr_api_key}"
    os_id = "159"
    plan_id = "vc2-1c-1gb"
    region_id = "yto"
    snapshot_description = "cloud-init-alpine-image"
    ssh_user_name = "root"
    shutdown_command = "${var.shutdown_command}"
    ssh_password     = "${var.ssh_password}"
    ssh_timeout      = "${var.ssh_wait_timeout}"
    ssh_username     = "root"
}

