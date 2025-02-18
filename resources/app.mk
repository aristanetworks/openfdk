#-------------------------------------------------------------------------------
#- Copyright (c) 2020 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Maintainers:
#-   fdk-support@arista.com
#-
#- Description:
#-   Project Makefile for an Application RPM for the Arista 7130
#-
#- Tags:
#-   license-arista-fdk-agreement
#-   license-bsd-3-clause
#-
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Environment / Config variables
#-------------------------------------------------------------------------------

PROJECT        ?= null
VERSION_ID     ?= 0.0.1.beta1
BUILD_ID       ?= 0

PROJECT_DIR    ?= $(CURDIR)
BUILD_DIR      ?= $(PROJECT_DIR)/build
ARISTA_FDK_DIR ?= ./../../
ARISTA_SRC_DIR  = $(ARISTA_FDK_DIR)/src

APP_INSTALL_DIR  = /opt/apps/$(PROJECT)
APP_STAGING_ROOT = $(BUILD_DIR)/$(PROJECT)
APP_STAGING_DIR  = $(APP_STAGING_ROOT)$(APP_INSTALL_DIR)

# We need bash for pipefail
SHELL = /bin/bash -o pipefail

# Use either a local RPM.spec file, or the one provided by the FDK
RPM_SPEC_FILE ?= $(firstword $(wildcard $(CURDIR)/rpm.spec $(ARISTA_FDK_DIR)/resources/rpm.spec))

# Set these to NULL -- if they don't exist yet, they're not going to.
BITSTREAMS  ?=
REGFILES    ?=
APPFILES    ?=
DRIVERFILES ?= $(wildcard $(ARISTA_FDK_DIR)/src/*/driver/*)

APP_BUILD_SQUASHFS ?=

# Extra app targets in APP_STAGING_DIR
EXTRA_APP_FILES     ?=
APP_SWIX_EXTRA_RPMS ?=

# Extra directories in APP_STAGING_DIR (outside of APP_INSTALL_DIR) which should be
# included in the app rpm
EXTRA_APP_DIRS ?=

#-------------------------------------------------------------------------------
# Rules for building python venvs
#-------------------------------------------------------------------------------

PYTHON2_ENV = $(BUILD_DIR)/python2_env
PYTHON2 	= $(PYTHON2_ENV)/bin/python
PIP2        = $(PYTHON2_ENV)/bin/pip

PYTHON3_ENV = $(BUILD_DIR)/python3_env
PYTHON3 = $(PYTHON3_ENV)/bin/python
PIP3    = $(PYTHON3_ENV)/bin/pip

$(PYTHON2_ENV):
	virtualenv --quiet $@
	$@/bin/python -m pip install --upgrade pip==20.3.4 --disable-pip-version-check

$(PYTHON2) $(PIP2): $(PYTHON2_ENV)
	@

$(PYTHON3_ENV):
	python3 -m venv $@
	$@/bin/python -m pip install --upgrade pip wheel

$(PYTHON3) $(PIP3): $(PYTHON3_ENV)
	@

#-------------------------------------------------------------------------------
# Rules for creating directories
#-------------------------------------------------------------------------------

$(BUILD_DIR)/%/:
	@mkdir -p $@

#-------------------------------------------------------------------------------
# Build all bitstreams
#-------------------------------------------------------------------------------

APP_BITS = $(foreach bitstream,$(BITSTREAMS),$(APP_STAGING_DIR)/fpga/$(bitstream).bit)

$(APP_STAGING_DIR)/fpga/%.bit: \
			$(BUILD_DIR)/vivado_results/%.bit
	@mkdir -p $(@D)
	@cp $< $@

#-------------------------------------------------------------------------------
# Copy App files to build directory
# NOTE: Eventually there should be a software.mk that builds the python project
#-------------------------------------------------------------------------------

APP_REGS     = $(patsubst $(PROJECT_DIR)/src/%,$(APP_STAGING_DIR)/fpga/%,$(REGFILES))
APP_FILES    = $(patsubst $(ARISTA_FDK_DIR)/resources/%,$(APP_STAGING_DIR)/%, \
                 $(patsubst $(PROJECT_DIR)/src/%,$(APP_STAGING_DIR)/%,$(APPFILES))) \
                 $$(EXTRA_APP_FILES)
DRIVER_FILES = $(patsubst $(ARISTA_FDK_DIR)/src/%,$(APP_STAGING_DIR)/drivers/%,$(DRIVERFILES))

$(APP_STAGING_DIR)/%.py: \
			$(PROJECT_DIR)/src/%.py
	mkdir -p $(@D)
	sed \
		-e "s/__version__\s*=\s*['\"]UNVERSIONED['\"]/__version__ = \"$(VERSION_ID)\"/" \
		-e "s/__buildid__\s*=\s*0/__buildid__ = $(BUILD_ID)/" \
		$< > $@

$(APP_STAGING_DIR)/fpga/% \
$(APP_STAGING_DIR)/%: \
			$(PROJECT_DIR)/src/%
	@mkdir -p $(@D)
	cp $< $@

$(APP_STAGING_DIR)/eos:
	@mkdir -p $@

$(APP_STAGING_DIR)/eos/libapp: \
			| $$(@D)
	ln -sf $(APP_INSTALL_DIR)/libapp $@

$(APP_STAGING_DIR)/eos/%: \
			$(PROJECT_DIR)/src/eos/% \
			| $(APP_STAGING_DIR)/eos/libapp
	cp $< $@

$(APP_STAGING_DIR)/libapp/%: \
			$(ARISTA_FDK_DIR)/resources/libapp/%
	@mkdir -p $(@D)
	cp $< $@

$(APP_STAGING_DIR)/drivers/%/:
	mkdir -p $(@D)

$(APP_STAGING_DIR)/drivers/%: \
			$(ARISTA_FDK_DIR)/src/% \
			| $$(@D)/
	cp $< $@
	if [ -d $(APP_STAGING_DIR)/eos ]; then \
	    ln -s $(APP_INSTALL_DIR)/drivers/$* $(APP_STAGING_DIR)/eos/; \
	fi
	if [ -f $(APP_STAGING_DIR)/example.py ]; then \
	    ln -s $(APP_INSTALL_DIR)/drivers/$* $(APP_STAGING_DIR)/; \
	fi

#-------------------------------------------------------------------------------
# Build Application TAR Ball
#-------------------------------------------------------------------------------

APP_TARBALL = $(BUILD_DIR)/$(PROJECT)-$(VERSION_ID).tar.gz

ifneq ($(APP_CLI_EXTENSIONS),)
EXTRA_APP_DIRS += /usr/share/CliExtension/
APP_AGENTS_TO_RESTART += ConfigAgent
endif

$(APP_TARBALL): \
			$(APP_BITS) \
			$(APP_REGS) \
			$(APP_FILES) \
			$(DRIVER_FILES) \
			$(abspath $(patsubst %,$(APP_STAGING_ROOT)/%,$(APP_DAEMONS)))

ifneq ($(APP_DAEMONS),)
	# ensure that any daemons are executable
	chmod a+x $(patsubst %,$(APP_STAGING_ROOT)/%,$(APP_DAEMONS))
endif
ifneq ($(APP_CLI_EXTENSIONS),)
	mkdir -p $(APP_STAGING_ROOT)/usr/share/CliExtension
	ln -s $(APP_CLI_EXTENSIONS) $(APP_STAGING_ROOT)/usr/share/CliExtension/
endif
	@cd $(@D) && tar cvfz $@ $(PROJECT)

ifeq ($(APP_SWIX)$(APP_RPM),)
# neither set, build swix only
APP_SWIX = $(PROJECT)-$(VERSION).swix
endif

ifeq ($(APP_SWIX),)
# not building swix
APP_BUILD_SQUASHFS =
APP_STUB_RPM =
else
# building swix
ifneq ($(APP_BUILD_SQUASHFS),)
APP_SQUASHFS = $(BUILD_DIR)/$(patsubst %.swix,%.squashfs,$(notdir $(APP_SWIX)))
ifeq ($(APP_RPM),)
APP_STUB_RPM = $(BUILD_DIR)/$(PROJECT)-stub-$(VERSION_ID).x86_64.rpm
else
APP_STUB_RPM = $(BUILD_DIR)/$(subst $(PROJECT),$(PROJECT)-stub,$(notdir $(APP_RPM)))
endif
endif
endif

BUILD_RPM      = $(BUILD_DIR)/$(patsubst %.x86_64.rpm,%-$(BUILD_ID).x86_64.rpm,$(notdir $(APP_RPM)))
ifneq ($(APP_STUB_RPM),)
BUILD_STUB_RPM = $(patsubst %.x86_64.rpm,%-$(BUILD_ID).x86_64.rpm,$(notdir $(APP_STUB_RPM)))
endif

#-------------------------------------------------------------------------------
# Build Application RPMs
#-------------------------------------------------------------------------------

ifneq ($(APP_RPM)$(APP_STUB_RPM),)
RPMBUILD_DIR      ?= $(BUILD_DIR)/rpmbuild/
RPMBUILD           = rpmbuild --define="_topdir $(RPMBUILD_DIR)"
RPMBUILD_SOURCEDIR = $(shell $(RPMBUILD) --eval "%{_sourcedir}")
RPMBUILD_RPMDIR    = $(shell $(RPMBUILD) --eval "%{_rpmdir}")
endif

ifneq ($(APP_RPM),)
$(APP_RPM): \
			$(BUILD_RPM)
	@mkdir -p $(@D)
	@mv $< $@

$(BUILD_RPM): \
			$(APP_TARBALL) \
			| $(BUILD_STUB_RPM)
	@mkdir -p $(RPMBUILD_SOURCEDIR)
	@cp $(APP_TARBALL) $(RPMBUILD_SOURCEDIR)
ifneq ($$(EXTRA_APP_DIRS),)
	@echo $(EXTRA_APP_DIRS)|tr ' ' '\n' > $(BUILD_DIR)/extradirs.spec
else
	@rm -f $(BUILD_DIR)/extradirs.spec
endif
	$(RPMBUILD) -ba $(RPM_SPEC_FILE) \
	    --define="appname $(PROJECT)" \
	    --define="version $(VERSION_ID)" \
	    --define="release $(BUILD_ID)" \
	    $(if $(APP_CLI_PLUGINS),--define="cliplugins $(APP_CLI_PLUGINS)") \
	    $(if $(EXTRA_APP_DIRS),--define="extradirs $(BUILD_DIR)/extradirs.spec") \
	    --define="source  $(notdir $(APP_TARBALL))"
	@cp $(RPMBUILD_RPMDIR)/x86_64/$(@F) $@
endif # ifneq ($(APP_RPM),)

ifneq ($(APP_STUB_RPM),)
$(APP_STUB_RPM): \
			$(BUILD_STUB_RPM)
	@mkdir -p $(@D)
	@mv $< $@

$(BUILD_STUB_RPM): \
			$(APP_TARBALL)
	@mkdir -p $(@D)
	@mkdir -p $(RPMBUILD_SOURCEDIR)
	@cp $(APP_TARBALL) $(RPMBUILD_SOURCEDIR)
ifneq ($(EXTRA_APP_DIRS),)
	@echo $(EXTRA_APP_DIRS)|tr ' ' '\n' > $(BUILD_DIR)/extradirs.spec
endif
	$(RPMBUILD) -ba $(RPM_SPEC_FILE) \
	    --define="appname $(PROJECT)" \
	    --define="version $(VERSION_ID)" \
	    --define="release $(BUILD_ID)" \
	    $(if $(APP_CLI_PLUGINS),--define="cliplugins $(APP_CLI_PLUGINS)") \
	    $(if $(EXTRA_APP_DIRS),--define="extradirs $(BUILD_DIR)/extradirs.spec") \
	    --define="source  $(notdir $(APP_TARBALL))" \
	    --define "stubrpm 1"
	@cp $(RPMBUILD_RPMDIR)/x86_64/$(@F) $@
endif # ifneq ($(APP_STUB_RPM),)

ifneq ($(APP_SWIX),)
#-------------------------------------------------------------------------------
# Build Application SWIX
#-------------------------------------------------------------------------------

SWIX_BUILD_DIR ?= $(BUILD_DIR)/swixbuild

APP_MANIFEST_YAML = $(SWIX_BUILD_DIR)/manifest.yaml

# EOS version that this app supports
# may be overridden in app makefile
APP_EOS_VERSION ?= '4.{23-99}.{0-99}*'

# Create the manifest.yaml required to install the extension.
# APP_AGENTS_TO_RESTART is a list of agents that the app needs to have
# restarted after installation.  If the stub RPM contains a CliExtension,
# ConfigAgent will be automatically added to this list, and any duplicate
# agent names will be discarded by the magic sed command.
$(SWIX_BUILD_DIR) $(BUILD_DIR)/ $(BUILD_DIR):
	@mkdir -p $@

ifeq ($(APP_BUILD_SQUASHFS),)
SWIX_RPM = $(APP_RPM)
else
SWIX_RPM = $(APP_STUB_RPM)

$(APP_SQUASHFS): \
			$(SWIX_BUILD_DIR) \
			$(APP_TARBALL) \
			| $(SWIX_BUILD_DIR)
	@rm -f $@
	@mksquashfs $(APP_STAGING_DIR) $@ -processors 8 -all-root -no-progress -noappend -comp xz -Xbcj x86
endif # ifeq ($(APP_BUILD_SQUASHFS),)

$(APP_MANIFEST_YAML): \
			$(SWIX_RPM) \
			| $(SWIX_BUILD_DIR)
	@printf "%s\n" \
		"metadataVersion: 1.0" \
		"version:" \
		"  - ${APP_EOS_VERSION}:" \
		"    - all" > $@
ifneq ($(APP_BUILD_SQUASHFS),)
	@printf "%s\n" \
		"    - $(notdir $(APP_SQUASHFS)):" \
		"      - mount: $(APP_INSTALL_DIR)" >> $@
endif
ifneq ($(APP_AGENTS_TO_RESTART),)
	@AGENTS_TO_RESTART="$(APP_AGENTS_TO_RESTART)"; \
		echo "agentsToRestart:" >> $@; \
		for agent in $$(echo "$${AGENTS_TO_RESTART}"|sed ':s;s/\(\<\S*\>\)\(.*\)\<\1\>/\1\2/g;ts'); do \
			echo "  - $${agent}" >> $@; \
		done
endif

# This uses "python3 -m pip install" instead of "pip3 install" so that it works
# even if $(SWIX_BUILD_DIR) is longer than the maximum allowed length of a
# "#!" path ( 127 characters).  swix-create is run in a similar manner for the
# same reason.
SWITOOLS_VENV = swi-tools

$(APP_SWIX): \
			$(SWIX_RPM) \
			$(APP_MANIFEST_YAML) \
			$(APP_SQUASHFS) \
			$$(APP_SWIX_EXTRA_RPMS)
	@mkdir -p $(@D)
	@cp $(SWIX_RPM) $(SWIX_BUILD_DIR)
	@cd $(SWIX_BUILD_DIR) \
	    && python3 -m venv $(SWITOOLS_VENV) \
	    && source $(SWITOOLS_VENV)/bin/activate \
	    && python3 -m pip install switools \
	    && python3 $(SWITOOLS_VENV)/bin/swix-create -i $(APP_MANIFEST_YAML) $(@F) $(<F) $(APP_SQUASHFS) $(APP_SWIX_EXTRA_RPMS)
	@mv $(SWIX_BUILD_DIR)/$(@F) $@
endif # ifneq ($(APP_SWIX),)

#-------------------------------------------------------------------------------
# Additional rules
#-------------------------------------------------------------------------------

targets::
	@printf "%s\n" \
		'' \
		'#-------------------------------------------------------------------------------' \
		'Application Project Generation:' \
		'    Dependencies : Unix Shell' \
		'                   rpmbuild' \
		'' \
		'    <PROJECT>-<VERSION_ID>.x86_64.rpm:' \
		'        Description  : Generates an RPM inclusive of all fpga images listed in <BITSTREAMS>.' \
		'        Artifact     : <PROJECT_DIR>/<PROJECT>-<VERSION_ID>.x86_64.rpm' \
		'        Requirements : <PROJECT>        - Project name' \
		'                       <VERSION_ID>     - Version number' \
		'                       <BUILD_ID>       - Build number' \
		'                       <ARISTA_FDK_DIR> - Arista FDK Directory' \
		'                       <BITSTREAMS>     - List of FPGA bitstreams to include' \
		'                       <APPFILES>       - List of application files to include' \
		'                       src/*-cfg.json   - A <PROJECT_DIR>/src/*-cfg.json file must be provided for each bitstream in <BITSTREAMS>' \
		'' \
		'    Eg. "make $(PROJECT)-$(VERSION_ID).x86_64.rpm"' \
		'' \
		'    Current Project Settings:' \
		'        <PROJECT>        - $(PROJECT)' \
		'        <VERSION_ID>     - $(VERSION_ID)' \
		'        <BUILD_ID>       - $(BUILD_ID)' \
		'        <ARISTA_FDK_DIR> - $(ARISTA_FDK_DIR)' \
		''

clean::
	rm -f *.rpm
	rm -f *.swix
	rm -rf $(BUILD_DIR)
