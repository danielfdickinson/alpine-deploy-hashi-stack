ALPINE_BASE_VERSION=3.15
ALPINE_PATCH_VERSION=4
ALPINE_FULL_VERSION=${ALPINE_BASE_VERSION}$(if ${ALPINE_PATCH_VERSION},.)${ALPINE_PATCH_VERSION}
INSTANCE_VERSION=0.1.2-alpha.10
INSTANCE_FULL_VERSION=${INSTANCE_VERSION}_${ALPINE_FULL_VERSION}
INSTANCE_EXTRA_VERSION=2
INSTANCE_NAME=nocloud-metadata

all:  install

clean:
	rm -f instance/*.plan

instance/.terraform.lock.hcl:
	cd instance && terraform init

instance/${INSTANCE_NAME}_${INSTANCE_FULL_VERSION}.plan: instance/.terraform.lock.hcl
	cd instance && TF_VAR_instance_full_version=${INSTANCE_FULL_VERSION} TF_VAR_instance_name=${INSTANCE_NAME} TF_VAR_instance_extra_version=${INSTANCE_EXTRA_VERSION} terraform plan -out ${INSTANCE_NAME}_${INSTANCE_FULL_VERSION}.plan

# Builder will call this to install the application before running.
install: instance/${INSTANCE_NAME}_${INSTANCE_FULL_VERSION}.plan

deploy: instance/${INSTANCE_NAME}_${INSTANCE_FULL_VERSION}.plan
	cd instance && TF_VAR_instance_full_version=${INSTANCE_FULL_VERSION} TF_VAR_instance_name=${INSTANCE_NAME} TF_VAR_instance_extra_version=${INSTANCE_EXTRA_VERSION} terraform apply ${INSTANCE_NAME}_${INSTANCE_FULL_VERSION}.plan
	rm -f instance/${INSTANCE_NAME}_${INSTANCE_FULL_VERSION}.plan

destroy:
	cd instance && TF_VAR_instance_full_version=${INSTANCE_FULL_VERSION}  TF_VAR_instance_name=${INSTANCE_NAME} TF_VAR_instance_extra_version=${INSTANCE_EXTRA_VERSION} terraform destroy

# Builder uses this target to run your application.
run:
	echo "Not a runnable application"
