# clean-alpinelinux-qemu-image

Packer config/scripts for building a clean alpinelinux image to feed into packer builder for a cloud-init image

Inspired by [packer-alpine/alpine-iso-install.json at master · ketzacoatl/packer-alpine · GitHub](https://github.com/ketzacoatl/packer-alpine/blob/master/00-iso-install/alpine-iso-install.json).

Uses Terraform with libvirt provider (kvm machines) to test the images.

The Terraform project is inspired by [dmacvicar/terraform-provider-libvirt - ubuntu example on GitHub](https://github.com/dmacvicar/terraform-provider-libvirt/tree/main/examples/v0.12/ubuntu).

