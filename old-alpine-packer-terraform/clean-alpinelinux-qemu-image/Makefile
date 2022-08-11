ALPINE_BASE_VERSION=3.15
ALPINE_PATCH_VERSION=4
ALPINE_FULL_VERSION=${ALPINE_BASE_VERSION}$(if ${ALPINE_PATCH_VERSION},.)${ALPINE_PATCH_VERSION}
INSTANCE_NAMES=alpine-clean alpine-generic-cloud-init
INSTANCE_VERSION_alpine_clean=0.1.3
INSTANCE_VERSION_alpine_generic_cloud_init=0.3.3
INSTANCE_VERSION_default_version=0.1.3
INSTANCE_SOURCE_alpine_clean=qemu.clean-alpine-image
INSTANCE_SOURCE_default=qemu.cloud-init-alpine-image
INSTANCE_PACKAGES_alpine_clean="[]"
INSTANCE_PACKAGES_default_cloud_init="[\"ca-certificates\"]" # Missing dependency for cloud-init
INSTANCE_PACKAGES_alpine_generic_cloud_init="[\"ca-certificates\"]"  # Missing dependency for cloud-init

stamp_instance=$(word 1,$(subst _, ,$(subst stamps/,,$(subst .stamp,,$(1)))))
stamp_var_instance=$(subst -,_,$(1))

plan_instance=$(word 1,$(subst _, ,$(subst -test,,$(subst stamps/,,$(subst test/,,$(subst .plan,,$(1)))))))
plan_var_instance=$(subst -,_,$(1))

specific_source=${INSTANCE_SOURCE_$(call stamp_var_instance,$(call stamp_instance,$(1)))}
stamp_instance_source=$(if $(call specific_source,$(1)),$(call specific_source,$(1)),${INSTANCE_SOURCE_default})

specific_packages=${INSTANCE_PACKAGES_$(call stamp_var_instance,$(call stamp_instance,$(1)))}
instance_packages=PKR_VAR_instance_packages=$(if $(call specific_packages,$(1)),$(call specific_packages,$(1)),${INSTANCE_PACKAGES_default_cloud_init})

specific_version=${INSTANCE_VERSION_$(call stamp_var_instance,$(call stamp_instance,$(1)))}
stamp_instance_version=$(if $(call specific_version,$(1)),$(call specific_version,$(1)),${INSTANCE_VERSION_default_version})
instance_version=PKR_VAR_instance_version=$(call stamp_instance_version,$(1))

specific_plan_version=${INSTANCE_VERSION_$(call plan_var_instance,$(call plan_instance,$(1)))}
plan_instance_version=$(if $(call specific_plan_version,$(1)),$(call specific_plan_version,$(1)),${INSTANCE_VERSION_default_version})
instance_plan_version=TF_VAR_instance_version=$(call plan_instance_version,$(1))


instance_full_name=$(call stamp_instance,$(1))_$(call stamp_instance_version,$(1))
plan_instance_full_name=$(call plan_instance,$(1))_$(call plan_instance_version,$(1))

export

all: $(foreach instance,${INSTANCE_NAMES},stamps/${instance}_${INSTANCE_VERSION_$(subst -,_,${instance})}_${ALPINE_FULL_VERSION}.stamp)


stamps/%.stamp:
	mkdir -p output stamps
	PKR_VAR_alpine_base_version=${ALPINE_BASE_VERSION} PKR_VAR_alpine_full_version=${ALPINE_FULL_VERSION} $(if ${APK_REPO_BASES},PKR_VAR_apk_repo_bases=${APK_REPO_BASES}) PKR_VAR_instance=$(call stamp_instance,$@) $(call instance_version,$@) $(call instance_packages,$@) packer validate -var-file sources.pkrvars.hcl images-from-virt-iso
	PKR_VAR_alpine_base_version=${ALPINE_BASE_VERSION} PKR_VAR_alpine_full_version=${ALPINE_FULL_VERSION} $(if ${APK_REPO_BASES},PKR_VAR_apk_repo_bases=${APK_REPO_BASES}) PKR_VAR_instance=$(call stamp_instance,$@) $(call instance_version,$@) $(call instance_packages,$@) packer build -var-file sources.pkrvars.hcl -only $(call stamp_instance,$@).$(call stamp_instance_source,$@) images-from-virt-iso
	touch "$@"

clean:
	rm -f test/*.plan
	rm -f test/*.tfstate
	rm -rf output/*
	rm -f stamps/*

test/.terraform.lock.hcl:
	cd test && terraform init

test/%.plan: test/.terraform.lock.hcl
	cd test && TF_VAR_alpine_instance=$(call plan_instance,$@) TF_VAR_instance_full_version=$(call plan_instance_version,$@)_${ALPINE_FULL_VERSION} terraform plan -out "$(call plan_instance,$@)-test_$(call plan_instance_version,$@)_${ALPINE_FULL_VERSION}.plan"

stamps/%.plan: test/.terraform.lock.hcl test/%.plan
	cd test && TF_VAR_alpine_instance=$(call plan_instance,$@) TF_VAR_instance_full_version=$(call plan_instance_version,$@)_${ALPINE_FULL_VERSION} terraform apply "$(call plan_instance,$@)-test_$(call plan_instance_version,$@)_${ALPINE_FULL_VERSION}.plan"
	cd test && TF_VAR_alpine_instance=$(call plan_instance,$@) TF_VAR_instance_full_version=$(call plan_instance_version,$@)_${ALPINE_FULL_VERSION} terraform destroy -auto-approve
	touch "$@"

runtests:
	$(MAKE) -j1 test-all

# Builder will call this to install the application before running.
test-all: $(foreach instance,$(filter-out alpine-clean,${INSTANCE_NAMES}),stamps/${instance}-test_${INSTANCE_VERSION_$(subst -,_,${instance})}_${ALPINE_FULL_VERSION}.plan)

# Builder uses this target to run your application.
run: test/terraform.tfstate

