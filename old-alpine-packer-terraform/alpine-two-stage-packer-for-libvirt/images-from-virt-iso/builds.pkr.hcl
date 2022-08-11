build {
    name = "${var.image_name}"

    source "source.qemu.base-alpine-image" {
        vm_name = "${var.image_full_version}.qcow2"
    }

    provisioner "shell" {
        inline = [
            "apk update",
            "apk upgrade",
            # Required for obtaining IP address for use with Libvirt Terraform provider
            "apk add qemu-guest-agent ${local.image_packages}",
            "rc-update add qemu-guest-agent boot",
            # Time services are important for SSL etc.
            "rc-update add ntpd boot",
            # Clean up
            "rm -f /etc/ssh/ssh_host_*key*",
            "sync"
        ]
    }
}

