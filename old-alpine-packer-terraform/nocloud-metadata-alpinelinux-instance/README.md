# nocloud-metadata-alpinelinux-instance

Terraform for libvirt provider (kvm machines) to provision an Alpine Linux-based userdata server for use by a NoCloud (net) datasource.

This is used to provide provisioning data, including some secrets, to instances to be brought up with Terraform + Cloud-init without
storing the data/secrets unencrypted in the NoCloud ISO that is created.

Of course that does punt to the userdata server (which includes Vault to help deal with this).

