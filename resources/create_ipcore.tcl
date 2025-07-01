#-------------------------------------------------------------------------------
#- Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Maintainers:
#-   fdk-support@arista.com
#-
#- Description:
#-   Create a Vivado IPCore XCI from IPCore TCL
#-
#- Tags:
#-   license-arista-fdk-agreement
#-   license-bsd-3-clause
#-
#-------------------------------------------------------------------------------

proc init_usage {} {
    set usage "Vivado ipcore generation script"
    return $usage
}

proc init_options {} {
    set options {}
    lappend options [optparse::create_option_with_arg tfile "IPCore TCL File, i.e. */ip/<fpga_part>/*/*.tcl" $optparse::REQUIRED]
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

Project::generate_ipcore $opts(tfile)
