#-------------------------------------------------------------------------------
#- Copyright (c) 2020-2023 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Author:
#-   fdk-support@arista.com
#-
#- Description:
#-   Makefile to build all examples.
#-
#- Tags:
#-   license-arista-fdk-agreement
#-   license-bsd-3-clause
#-
#-------------------------------------------------------------------------------

EXAMPLES ?= $(patsubst %/Makefile,%,$(wildcard */Makefile))

BUILD_TARGETS ?= $(foreach e,$(EXAMPLES),build/$(e))

LOG_FILE_DIR ?= build/logs

SHELL=/bin/bash -o pipefail

# Disable use of the Xilinx TCL Store, which breaks when run in parallel.
export XILINX_LOCAL_USER_DATA = no

all: $(BUILD_TARGETS)
	@echo Build complete for $(BUILD_TARGETS)

.PHONY: $(BUILD_TARGETS)

$(LOG_FILE_DIR):
	mkdir -p $(LOG_FILE_DIR)

$(BUILD_TARGETS): |$(LOG_FILE_DIR)
	$(MAKE) -C $(@F) | tee $(LOG_FILE_DIR)/$(@F)__log.txt

clean:
	rm -rf build
	rm -rf $(foreach e,$(EXAMPLES),./$(e)/build)
	rm -rf $(foreach e,$(EXAMPLES),$(wildcard ./$(e)/*.rpm))
	rm -rf $(foreach e,$(EXAMPLES),$(wildcard ./$(e)/*.swix))
