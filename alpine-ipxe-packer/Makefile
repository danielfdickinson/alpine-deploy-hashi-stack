IMAGE_NAMES=cloud-init-base-alpine
#IMAGE_NAMES=base-alpine

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

