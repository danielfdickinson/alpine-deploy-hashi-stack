packer {
    required_plugins {
        libvirt = {
            version = "v0.3.1"
            source = "github.com/thomasklein94/libvirt"
        }

        vultr = {
            version = ">= v2.4.5"
            source  = "github.com/vultr/vultr"
        }
    }
}

source "libvirt" "cloud-init-alpine-image" {
    communicator {
        ssh_host = "${var.libvirt_ssh_host}"
        ssh_timeout = "${var.ssh_wait_timeout}"
        ssh_username = "${var.ssh_username}"
        ssh_clear_authorized_keys = true
        ssh_agent_auth = true
    }

    libvirt_uri = "${var.libvirt_uri}"
    memory = "${var.libvirt_memory}"
    vcpu = "${var.libvirt_num_vcpu}"

    boot_devices = ["hd","network"]

    network_address_source = "${var.libvirt_address_source}"

    network_interface {
        type = "${var.libvirt_network_type}"
        network = "${var.libvirt_pxe_network}"
        bridge = "${var.libvirt_pxe_bridge}"
        alias = "communicator"
        model = "virtio"
        mac = "${var.libvirt_pxe_mac}"
    }

    graphics {
        type = "vnc"
    }

    volume {
        alias = "artifact"
        name = "${local.image_full_name}"
        capacity = "${var.libvirt_image_size}"
        pool = "${var.libvirt_pool}"
        bus = "virtio"
        target_dev = "vda"
    }
}

source "vultr" "cloud-init-alpine-image" {
    ssh_timeout = "${var.ssh_wait_timeout}"
    ssh_username = "${var.ssh_username}"
    ssh_clear_authorized_keys = true
    ssh_agent_auth = true
    api_key = "${var.vultr_api_key}"
    os_id = "159" # Custom; allows iPXE with script_id for PXE script
    enable_ipv6 = (var.vultr_enable_ipv6 == "true")
    plan_id = "${var.vultr_plan_id}"
    region_id = "${var.vultr_region_id}"
    script_id = "${var.vultr_ipxe_script_id}"
    state_timeout = "10m"
    snapshot_description = "${local.image_full_name}"
}

