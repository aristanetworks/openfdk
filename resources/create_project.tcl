#-------------------------------------------------------------------------------
#- Copyright (c) 2019-2023 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Author:
#-   fdk-support@arista.com
#-
#- Description:
#-   Create a Vivado project for a given project config
#-
#- Tags:
#-   license-arista-fdk-agreement
#-   license-bsd-3-clause
#-
#-------------------------------------------------------------------------------

proc init_usage {} {
    set usage "Vivado project generation script"
    return $usage
}

proc init_options {} {
    set options {}
    lappend options [optparse::create_option_with_arg cfg "Path to target config file, i.e. */<variant>-<board_standard>-cfg.json" $optparse::REQUIRED]
    lappend options [optparse::create_option_with_arg projdir "Path to project directory" $optparse::REQUIRED]
    lappend options [optparse::create_option_with_arg proj "Name of Vivado project" $optparse::OPTIONAL "project"]
    lappend options [optparse::create_option_with_arg srcs "Path to JSON file containing additional sources in the same format as <cfg>" $optparse::OPTIONAL]
    lappend options [optparse::create_option_with_arg files "Paths to additional sources in TCL dict format e.g. -files 'sources_1 {foo bar} constrs_1 {foo}'" $optparse::OPTIONAL]
    lappend options [optparse::create_option_with_arg vhdl_ftype "Vivado VHDL file type to be applied to all VHDL source files" $optparse::OPTIONAL "VHDL 2008"]
    lappend options [optparse::create_option_without_arg import_srcs "Imports (copies) all source files to project.srcs directory"]
    return $options
}

set script_dir [file dirname [file normalize [info script]]]
set fdk_dir    [file normalize $script_dir/..]
source $script_dir/optparse.tcl
source $script_dir/project.tcl

# Setup options for the script
set options [init_options]
set usage [init_usage]

# Parse options
array set opts [optparse::parse_options $options $usage]

Project::create_new_project $opts(cfg) $opts(proj) $opts(projdir) $fdk_dir $opts(srcs) $opts(files) $opts(vhdl_ftype) $opts(import_srcs)
