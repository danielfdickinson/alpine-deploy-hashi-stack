# Alpine two stage Packer for Libvirt

Makefiles and Packer configuration for generating a Libvirt/KVM image from ISO
and more configuration for taking that and generating Libvirt/KVM cloud-init
enabled images.

Inspired by [packer-alpine/alpine-iso-install.json at master · ketzacoatl/packer-alpine · GitHub](https://github.com/ketzacoatl/packer-alpine/blob/master/00-iso-install/alpine-iso-install.json).

Uses Terraform with libvirt provider (kvm machines) to test the images.

The Terraform project is inspired by [dmacvicar/terraform-provider-libvirt - ubuntu example on GitHub](https://github.com/dmacvicar/terraform-provider-libvirt/tree/main/examples/v0.12/ubuntu).
