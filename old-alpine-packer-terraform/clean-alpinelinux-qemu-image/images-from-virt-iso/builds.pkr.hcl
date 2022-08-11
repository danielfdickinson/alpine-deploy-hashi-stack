build {
    name = "${var.instance}"

    source "source.qemu.clean-alpine-image" {
        vm_name = "${var.instance}_${var.instance_version}_${var.alpine_full_version}.qcow2"
    }

    provisioner "shell" {
        inline = [
            "apk update",
            "rc-update add ntpd boot",
            "service ntpd start",
            "rm -f /etc/ssh/ssh_host_*key*",
            "sync"
        ]
    }
}

build {
    name = "${var.instance}"

    source "source.qemu.cloud-init-alpine-image" {
        vm_name = "${var.instance}_${var.instance_version}_${var.alpine_full_version}.qcow2"
    }

    provisioner "file" {
        content = templatefile("files/motd.tmpl", {
            instance_name = var.instance
            instance_version = var.instance_version
            alpine_full_version = var.alpine_full_version
            timestamp = local.timestamp
        })
        destination = "/etc/motd"
    }

    provisioner "shell" {
        inline = [
            "echo '${local.apk_community_repos_nl}' >>/etc/apk/repositories",
            "apk update",
            "apk add cloud-init python3 qemu-guest-agent util-linux doas e2fsprogs-extra ca-certificates py3-netifaces bash ${local.instance_packages}",
            "rc-update add ntpd boot",
            "rc-update add qemu-guest-agent boot",
            "service ntpd restart",
            "setup-cloud-init",
            "mkdir -m 0700 /tmp/extra_files",
            "mkdir -m 0700 /tmp/extra_files/common"
        ]
    }

    # Note that ${var.extra_files_dir}/extra_script.sh MUST exist although
    # it can be an empty script (no-op)
    provisioner "file" {
        source = "${local.extra_files_dir}/"
        destination = "/tmp/extra_files/"
    }

    # Note that ${var.extra_files_dir}/common/extra_script.sh MUST exist although
    # it can be an empty script (no-op)
    provisioner "file" {
        source = "${local.extra_files_common_dir}/"
        destination = "/tmp/extra_files/${var.extra_files_common}/"
    }

    provisioner "shell" {
        inline = [
            ". /tmp/extra_files/${var.extra_files_common}/extra_script.sh",
            # private_ca_cert should be in 'extra_files' and moved in place via that script
            # we fail the script if private_ca_cert is defined but does not exist in the expected location
            "if test -n \"${var.private_ca_cert}\"; then if ! test -s /usr/local/share/ca-certificates/\"${var.private_ca_cert}\"; then exit 1; else if ! test -L /etc/ssl/certs/ca-cert-$(basename $(basename \"${var.private_ca_cert}\" .crt) .pem).pem; then exit 1; fi; fi; fi",
            ". /tmp/extra_files/extra_script.sh"
        ]
    }

    # Clean up; no login possible without cloud-init provisioning
    provisioner "shell" {
        inline = [
            "rm -rf /tmp/extra_files",
            "rm -f /etc/ssh/ssh_host_*key*",
            "sed -i -e '$a\\key_types_to_generate=\"rsa ed25519\"' /etc/conf.d/sshd",
            "sed -i -e '/^PermitRootLogin yes/d' /etc/ssh/sshd_config",
            "sed -i -e '$a\\KbdInteractiveAuthentication no' /etc/ssh/sshd_config",
            "sed -i -e '/^root:/s/^root:[^:]*:/root:!:/' /etc/shadow",
            "passwd -l root",
            "rm -rf /tmp/*",
            "sync"
        ]
    }
}

