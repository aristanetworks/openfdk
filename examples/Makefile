#-------------------------------------------------------------------------------
#- Copyright (c) 2020 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Maintainers:
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

SHELL = /bin/bash -o pipefail

EXAMPLES ?= $(patsubst %/Makefile,%,$(wildcard */Makefile))

BUILD_TARGETS ?= $(foreach e, $(EXAMPLES), build/$(e))

EXAMPLE_CONFIGS    ?= $(filter-out $(wildcard disable*/*/*), $(wildcard */conf/*.json))
EXAMPLE_BITSTREAMS ?= $(abspath $(foreach conf,$(basename $(EXAMPLE_CONFIGS)),$(addsuffix .bitstream,$(basename $(subst conf/,,$(conf))))))

LOG_FILE_DIR ?= build/logs

# Disable use of the Xilinx TCL Store, which breaks when run in parallel.
export XILINX_LOCAL_USER_DATA = no

$(LOG_FILE_DIR):
	mkdir -p $(LOG_FILE_DIR)

.PHONY: all
all: \
			$(BUILD_TARGETS)
	@echo Build complete for $(BUILD_TARGETS)

.PHONY: $(BUILD_TARGETS)
$(BUILD_TARGETS): \
			| $(LOG_FILE_DIR)
	$(MAKE) -C $(@F) | tee $(LOG_FILE_DIR)/$(@F)__log.txt

$(PROJECT_DIR)/%.bitstream:
	make -C $(@D) $(notdir $@)

.PHONY: build_bitstream
build_bitstream: $(EXAMPLE_BITSTREAMS)
	@

.PHONY: clean
clean:
	rm -rf build
	rm -rf $(foreach e,$(EXAMPLES),./$(e)/build $(wildcard ./$(e)/*.rpm) $(wildcard ./$(e)/*.swix))
