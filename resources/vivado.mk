#-------------------------------------------------------------------------------
#- Copyright (c) 2019 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Maintainers:
#-   fdk-support@arista.com
#-
#- Description:
#-   Makefile for generating and building bitstreams for the Arista 7130
#-
#- Tags:
#-   license-arista-fdk-agreement
#-   license-bsd-3-clause
#-
#-------------------------------------------------------------------------------

.SECONDEXPANSION:
.SECONDARY:

#-------------------------------------------------------------------------------
# Environment / Config variables
#-------------------------------------------------------------------------------

PROJECT_DIR    ?= $(CURDIR)
BUILD_DIR      ?= $(PROJECT_DIR)/build
ARISTA_FDK_DIR ?= $(PROJECT_DIR)/../..
ARISTA_SRC_DIR  = $(abspath $(ARISTA_FDK_DIR)/src)

IMPORTSRCS ?= 0
BITSTREAMS ?= $(sort $(foreach cfg, $(wildcard src/*-cfg.json), $(firstword $(subst -cfg, ,$(basename $(notdir $(cfg)))))))
XPRS        = $(addsuffix -project, $(BITSTREAMS))

SHELL = /bin/bash -o pipefail

VIVADO_PROJECT_CMD_PREFIX ?= $(VIVADO_CMD_PREFIX)
VIVADO_SYNTH_CMD_PREFIX   ?= $(VIVADO_CMD_PREFIX)

#-------------------------------------------------------------------------------
# Targets
#-------------------------------------------------------------------------------

.PHONY: $(BITSTREAMS)
$(BITSTREAMS): \
			$(BUILD_DIR)/vivado_results/$$@.bit
	@echo 'Bitstream generated at $<'

.PHONY: $(XPRS)
# This is a "static pattern rule" which has the following syntax:
# targets: target-pattern: prereq-patterns
#        recipe
$(XPRS): %-project: \
			$(BUILD_DIR)/%/project.xpr
	@echo 'Project created at $(<D)'

#-------------------------------------------------------------------------------
# Create Bitstreams
#-------------------------------------------------------------------------------

ifeq ($(IMPORTSRCS),1)
  EXTRA_TCL_SWITCH = "-import_srcs"
endif

$(BUILD_DIR)/vivado_results/%.bit: \
			$(BUILD_DIR)/%/project.runs/impl_1/board_top.bit
	@mkdir -p $(@D)
	@cp $< $@

# Sets BITFILE_DEPS to all files included in the .json configs using jq
$(BUILD_DIR)/%/project.runs/impl_1/board_top.bit \
$(BUILD_DIR)/%/project.xpr: BITFILE_DEPS=$(shell \
		jq -r '. | {constrs_1,sources_1}[][] | \
			sub("\\$${ARISTA_FDK_DIR}";"$(abspath $(ARISTA_FDK_DIR))") | \
			sub("\\$${PROJECT_DIR}";"$(abspath $(PROJECT_DIR))") | \
			sub("\\$${BUILD_DIR}";"$(abspath $(BUILD_DIR))")' \
			$(PROJECT_DIR)/src/$*-cfg.json $(SOURCE_FILES))

# Sets BITFILE_DEPS_MD5S to be used by mm-bamboo for cache hash sensitivity
$(BUILD_DIR)/%/project.runs/impl_1/board_top.bit: BITFILE_DEPS_MD5S=$(shell \
		jq -n -r \
			--slurpfile arista_src $(ARISTA_FDK_DIR)/arista_src.md5 \
			--slurpfile variant_src $(PROJECT_DIR)/src/$*-cfg.json \
			'$$arista_src[] | \
				with_entries( select( .key == ( \
				$$variant_src[] | {constrs_1,sources_1}[][] | \
					sub("\\$${ARISTA_FDK_DIR}";"$(notdir $(ARISTA_FDK_DIR))") | \
					sub("\\$${PROJECT_DIR}";"$(notdir $(ARISTA_FDK_DIR))/examples/$(PROJECT)") \
				))) | to_entries[] | .value' \
	)

$(BUILD_DIR)/%/project.runs/impl_1/board_top.bit: \
			$(BUILD_DIR)/%/project.xpr \
			$(BUILD_DIR)/%/launch_impl.tcl
	@mkdir -p $(@D) && \
	cd $(<D) && \
	$(VIVADO_SYNTH_CMD_PREFIX) \
		vivado \
			-mode batch \
			-source launch_impl.tcl -notrace \
			-tclargs \
				$(<F) \
			2>&1 \
		| tee $(@)__log.txt

$(BUILD_DIR)/%/project.xpr: \
			$(ARISTA_FDK_DIR)/resources/create_project.tcl \
			$(PROJECT_DIR)/src/%-cfg.json \
			$$(BITFILE_DEPS)
	@mkdir -p $(@D)
	$(if $(wildcard $*.tcl), \
		cd $(@D) && \
		$(VIVADO_PROJECT_CMD_PREFIX) \
			vivado \
				-mode batch \
				-source ../../$*.tcl -notrace \
				2>&1 \
			| tee $(@)__log.txt;, \
		cd $(@D) && \
		$(VIVADO_PROJECT_CMD_PREFIX) \
			vivado \
				-mode batch \
				-source $(ARISTA_FDK_DIR)/resources/create_project.tcl -notrace \
				-tclargs \
					$(EXTRA_TCL_SWITCH) \
					-cfg $(PROJECT_DIR)/src/$*-cfg.json \
					-proj project \
					-projdir . \
					-srcs $(SOURCE_FILES) \
				2>&1 \
			| tee $(@)__log.txt \
	)

$(BUILD_DIR)/%/launch_impl.tcl:
	@mkdir -p $(@D); \
	printf "%s\n" \
		'set proj [lindex $$argv 0]' \
		'open_project $$proj' \
		'reset_runs synth_1' \
		'launch_runs synth_1' \
		'wait_on_run synth_1' \
		'launch_runs impl_1 -to_step write_bitstream' \
		'wait_on_run impl_1' \
		> $@

$(ARISTA_SRC_DIR)/%.xci: \
			$(ARISTA_FDK_DIR)/resources/create_ipcore.tcl \
			$(ARISTA_SRC_DIR)/%.tcl
	@cd $(@D) && \
	$(VIVADO_PROJECT_CMD_PREFIX) \
		vivado \
			-mode batch \
			-source $(ARISTA_FDK_DIR)/resources/create_ipcore.tcl -notrace \
			-tclargs \
				-tfile $*.tcl \
			2>&1 \
		| tee $(@)__log.txt

#-------------------------------------------------------------------------------
# Additional rules
#-------------------------------------------------------------------------------

.PHONY: targets
targets::
	@printf "%s\n" \
		'' \
		'#-------------------------------------------------------------------------------' \
		'FPGA Bitstream Generation:' \
		'    Dependencies : Unix Shell' \
		'                   Xilinx Vivado 2019.2 or 2023.1 - Full License' \
		'' \
		'    <bitstream>:' \
		'        Description  : Generates a FPGA bitstream for <bitstream> if src/<bitstream>-cfg.json found.' \
		'        Artifact     : <PROJECT_DIR>/build/vivado_results/<bitstream>.bit' \
		'        Requirements : <ARISTA_FDK_DIR> - Arista FDK directory' \
		'                       src/*-cfg.json   - A <PROJECT_DIR>/src/<bitstream>-cfg.json file must be provided for each <bitstream>' \
		'        Optional     : <IMPORTSRCS>     - 0 : Add files to project from original source location' \
		'                                          1 : Import files to project after copying to <PROJECT_DIR>/build/<bitstream>/projects.srcs' \
		'' \
		'    <bitstream>-project:' \
		'        Description  : Generates a project for <bitstream> if src/<bitstream>-cfg.json found.' \
		'        Artifact     : <PROJECT_DIR>/build/<bitstream>/.' \
		'        Requirements : <ARISTA_FDK_DIR> - Arista FDK directory' \
		'                       src/*-cfg.json   - A <PROJECT_DIR>/src/<bitstream>-cfg.json file must be provided for each <bitstream>' \
		'        Optional     : <IMPORTSRCS>     - 0 : Add files to project from original source location' \
		'                                          1 : Import files to project after copying to <PROJECT_DIR>/build/<bitstream>/projects.srcs' \
		'' \
		'    Where <bitstream> is a list inclusive of any of the following:' \
		$(foreach t, $(BITSTREAMS), \
			'        $(t)') \
		'' \
		'    Eg. "make $(lastword $(BITSTREAMS))-project" or "make $(lastword $(BITSTREAMS))"' \
		''

.PHONY: clean
clean::
	rm -rf vivado*
	rm -rf .Xil
