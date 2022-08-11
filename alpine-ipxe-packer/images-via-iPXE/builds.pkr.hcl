build {
    name = "${var.image_name}"

    sources = ["source.libvirt.cloud-init-alpine-image", "source.vultr.cloud-init-alpine-image"]

    provisioner "file" {
        destination = "/tmp/answers"
        content = templatefile("templates/answers.tmpl", {
            apk_repos = local.apk_base_repos
        })
    }

    provisioner "file" {
        content = templatefile("templates/motd.tmpl", {
            alpine_full_version = local.alpine_full_version
            image_full_version = local.image_full_name
            timestamp = local.timestamp
        })
        destination = "/etc/motd"
    }

    provisioner "shell" {
        expect_disconnect = true
        pause_after = "40s"
        inline = [
            "echo 'alpine\nalpine\nno\ny' | setup-alpine -f /tmp/answers",
            "mount /dev/vda3 /mnt",
            "cp -ar /root/.ssh /mnt/root/",
            "umount /mnt",
            "reboot"
        ]
    }

    provisioner "shell" {
        inline = [
            "apk update",
            "apk upgrade",
            # Required for obtaining IP address for use with Libvirt Terraform provider
            "apk add qemu-guest-agent ${local.image_packages}",
            "mkdir -m 0700 /tmp/extra_files",
            "mkdir -m 0700 /tmp/extra_files/common",
        ]
    }

    # Note that ${var.extra_files_dir}/extra_script.sh MUST exist although
    # it can be an empty script (no-op)
    provisioner "file" {
        source = "${local.extra_files_dir}/"
        destination = "/tmp/extra_files/"
    }

    # Note that ${var.extra_files_common_dir}/extra_script.sh MUST exist although
    # it can be an empty script (no-op)
    provisioner "file" {
        source = "${local.extra_files_common_dir}/"
        destination = "/tmp/extra_files/common/"
    }

    # Note that ${var.extra_files_dir}/common/extra_script.sh MUST exist although
    # it can be an empty script (no-op)
    provisioner "file" {
        content = templatefile("templates/common_extra_script.sh.tmpl", {
            base_image = (var.base_image == true) ? "true" : "false"
        })
        destination = "/tmp/extra_files/${var.extra_files_common}/extra_script.sh"
    }

    provisioner "shell" {
        inline = [
            ". /tmp/extra_files/extra_script.sh",
            ". /tmp/extra_files/${var.extra_files_common}/extra_script.sh"
        ]
    }

    provisioner "shell" {
        inline = [
            "if test '${(var.base_image == true) ? "true" : "false"}' != 'true'; then passwd -l root; fi",
            # Clean up
            "rm -f /etc/ssh/ssh_host_*key*",
            "rm -rf /tmp/*",
            "sync"
        ]
    }
}

