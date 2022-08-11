# Alpine image builder using iPXE and Packer

Makefiles and Packer configuration for generating Alpine Linux images using iPXE.
These are currently only available for Libvirt and Vultr.

Inspired by [packer-alpine/alpine-iso-install.json at master · ketzacoatl/packer-alpine · GitHub](https://github.com/ketzacoatl/packer-alpine/blob/master/00-iso-install/alpine-iso-install.json)
when the now Libvirt source was originally developed using a QEMU builder.

Uses Terraform with same provider to test the images.

The Terraform project is inspired by [dmacvicar/terraform-provider-libvirt - ubuntu example on GitHub](https://github.com/dmacvicar/terraform-provider-libvirt/tree/main/examples/v0.12/ubuntu).
