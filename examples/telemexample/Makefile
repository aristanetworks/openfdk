#-------------------------------------------------------------------------------
#- Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Author:
#-   fdk-support@arista.com
#-
#- Description:
#-   Project Makefile for building custom applications targeting the
#-   Arista 7130 development platforms
#-
#-   Licensed under BSD 3-clause license:
#-     https://opensource.org/licenses/BSD-3-Clause
#-
#- Tags:
#-   license-bsd-3-clause
#-
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Environment & Project variables
#-------------------------------------------------------------------------------

.SECONDEXPANSION:

PROJECT    ?= telemexample
VERSION_ID ?= 2.7.0.openfdk
BUILD_ID   ?= 6

PROJECT_DIR         = $(CURDIR)
ARISTA_FDK_VERSION ?= 2.7.0.openfdk
ARISTA_FDK_DIR     ?= $(PROJECT_DIR)/../../../arista_fdk-$(ARISTA_FDK_VERSION)
ARISTA_SRC_DIR      = $(ARISTA_FDK_DIR)/src

SOURCE_FILES = $(PROJECT_DIR)/src_files.json

BOARDSTD ?= $(sort $(foreach brd, $(wildcard src/*-cfg.json), $(wordlist 2,2, $(subst -, ,$(basename $(notdir $(brd)))))))
VARIANTS ?= $(sort $(foreach var, $(wildcard src/*-cfg.json), $(wordlist 1,1, $(subst -, ,$(basename $(notdir $(var)))))))

# Extract source files from config files
#   $1: Paths to config files
define parse_app_cfg
$(foreach src, $1, \
  $(if $(findstring json,$(src)), \
    $(shell cat $(src) | \
      jq -r '. \
        | with_entries( \
          select( \
            .key|contains("sources") or contains("constrs") \
          ) \
        ) \
        | flatten \
        | .[] \
        | sub("\\$${PROJECT_DIR}";"$(subst /,\/,$(PROJECT_DIR))") \
        | sub("\\$${ARISTA_FDK_DIR}";"$(subst /,\/,$(ARISTA_FDK_DIR))")'), \
    $(src) \
  ) \
)
endef

#-------------------------------------------------------------------------------
# Default Target
#-------------------------------------------------------------------------------

# List of application files to be built into the RPM
APPFILES = $(call parse_app_cfg,$(PROJECT_DIR)/src/app-cfg.json)

# List of register files to be built into the RPM
REGFILES = $(wildcard $(PROJECT_DIR)/src/*.csv)

# Create list of fpga bitstreams to be added to the application RPM
# Check that VARIANTS-BOARDSTD-cfg.json exists first...
PROJ_FILES = $(wildcard $(PROJECT_DIR)/src/*-cfg.json)
BITSTREAMS = $(foreach brd, $(BOARDSTD), \
                 $(foreach var, $(VARIANTS), \
                     $(if $(findstring $(var)-$(brd)-cfg.json, $(PROJ_FILES)), $(var)-$(brd))))

# build RPM and SWIX by default but no squashfs
APP_RPM            = $(PROJECT)-$(VERSION_ID).x86_64.rpm
APP_SWIX           = $(PROJECT)-$(VERSION_ID).swix
APP_BUILD_SQUASHFS =

.PHONY : all
all : $(APP_RPM) $(APP_SWIX)

#-------------------------------------------------------------------------------
# Additional targets
#-------------------------------------------------------------------------------

.PHONY: targets
targets::
	@printf "%s\n" \
	'' \
	'#-------------------------------------------------------------------------------' \
	'Helper Targets:' \
	'' \
	'    targets:' \
	'        Display this help message' \
	'    clean:' \
	'        Clean all generated files' \
	'' \
	'' \
	'#-------------------------------------------------------------------------------' \
	'Customised Project Makefile:' \
	'    Dependencies : Unix Shell' \
	'' \
	'    all:' \
	'        Description  : Calls Application RPM generation with customized variables' \
	'        Requirements : Refer to Application Project Generation helper' \
	'        Artifacts    : Refer to Application Project Generation helper' \
	'' \
	'    Eg. "make"' \
	'        "make BOARDSTD=$(lastword $(BOARDSTD))"' \
	''

.PHONY : clean
clean::


#-------------------------------------------------------------------------------
# Extra variables for building Muxcore targets
#-------------------------------------------------------------------------------

DRIVERFILES =

APP_CLI_PLUGINS = $(APP_INSTALL_DIR)/eos/TelemExampleCli.py
APP_CLI_EXTENSIONS = $(APP_INSTALL_DIR)/eos/TelemExample.yaml
APP_DAEMONS = $(APP_INSTALL_DIR)/eos/TelemExampleDaemon.py
APP_BUILD_SQUASHFS =
#-------------------------------------------------------------------------------
# Include rules
#-------------------------------------------------------------------------------

include $(ARISTA_FDK_DIR)/resources/app.mk
include $(ARISTA_FDK_DIR)/resources/vivado.mk

#-------------------------------------------------------------------------------
# Extra rules for building Telemexample targets
#-------------------------------------------------------------------------------

# This is used via secondary expansion, so OK to put here (after other .mk)
EXTRA_APP_FILES = $(APP_STAGING_DIR)/eos/python_deps2.zip $(APP_STAGING_DIR)/eos/python_deps3.zip

# Python requirements are packaged as a zip file in the app for now
$(APP_STAGING_DIR)/eos/python_deps3.zip: requirements.txt $(PYTHON3_ENV)
	@mkdir -p $(@D)
	mkdir -p $(BUILD_DIR)/python_deps3
	$(PYTHON3) -m pip install -r $< --target $(BUILD_DIR)/python_deps3
	cd $(BUILD_DIR)/python_deps3 && zip -q -r -o $@ *

$(APP_STAGING_DIR)/eos/python_deps2.zip: requirements.txt $(PYTHON2_ENV)
	@mkdir -p $(@D)
	mkdir -p $(BUILD_DIR)/python_deps2
	$(PYTHON2) -m pip install -r $< --target $(BUILD_DIR)/python_deps2
	cd $(BUILD_DIR)/python_deps2 && zip -q -r -o $@ *