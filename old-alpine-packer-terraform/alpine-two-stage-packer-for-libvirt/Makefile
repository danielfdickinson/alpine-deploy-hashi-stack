ALPINE_BASE_VERSION=3.15
ALPINE_PATCH_VERSION=4
ALPINE_FULL_VERSION=${ALPINE_BASE_VERSION}$(if ${ALPINE_PATCH_VERSION},.)${ALPINE_PATCH_VERSION}
IMAGE_NAMES=base-alpine vaulted-radicale
#IMAGE_NAMES=cloud-init-base-alpine cloud-init-radicale vaulted-base-alpine

export

all: install

install: $(foreach image,${IMAGE_NAMES},install-${image})

run: $(foreach image,${IMAGE_NAMES},run-${image})

clean: $(foreach image,${IMAGE_NAMES},clean-${image})

install-%:
	$(MAKE) -f Makefile.$(subst install-,,$@) install

run-%:
	$(MAKE) -j1 -f Makefile.$(subst run-,,$@) run

clean-%:
	$(MAKE) -j1 -f Makefile.$(subst clean-,,$@) clean
