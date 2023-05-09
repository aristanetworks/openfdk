#-------------------------------------------------------------------------------
#- Copyright (c) 2019-2023 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Author:
#-   fdk-support@arista.com
#-
#- Description:
#-   Helpers for create_project.tcl
#-
#- Tags:
#-   license-arista-fdk-agreement
#-   license-bsd-3-clause
#-
#-------------------------------------------------------------------------------

package require json

namespace eval Project {
    variable script_dir [file dirname [file normalize [info script]]]

    # Extract the board_standard from a */<variant>-<brdstd>-cfg.json config
    proc config_to_brdstd {config} {
        set brd_std [regsub {\w+-(\w+)-cfg.json} [file tail $config] {\1}]
        return $brd_std
    }

    # Get the corresponding FPGA for the brdstd
    proc get_fpga {brd_std fdk_dir} {
        set fd    [open "$fdk_dir/src/boards/$brd_std/board_conf.json" r]
        set jtext [read $fd]
        close $fd

        set tcldct [json::json2dict $jtext]
        return [dict get $tcldct FPGA_DEVICE]
    }

    # Create a Vivado project named $proj in directory $proj_dir for FPGA $fpga
    proc create_vivado_project {fpga proj proj_dir} {
        create_project -force $proj $proj_dir -part $fpga
        set_property default_lib work [current_project]
        set_property target_language VHDL [current_project]
    }

    # Get a dict of required source files
    proc get_sources {jfile arista_fdk_dir project_dir build_dir} {
        # Create an example project
        set fd [open $jfile r]
        set jtext [read $fd]
        close $fd

        set tcldct [json::json2dict $jtext]

        foreach key [dict keys $tcldct] {
            set val [dict get $tcldct $key]
            set val [string map [list {${ARISTA_FDK_DIR}} $arista_fdk_dir] $val]
            set val [string map [list {${BUILD_DIR}} $build_dir] $val]
            # Use [lrange ... 0 end] here to get rid of the braces around each file,
            # which becomes a problem when there is only one file in the list, i.e.
            # the command
            #   add_files {{<file1>}}
            # is interpreted incorrectly as adding {<file1>}, while
            #   add_files {{<file1>} {<file2>}}
            # is interpreted correctly as adding <file1> and <file2>.
            set val [lrange [string map [list {${PROJECT_DIR}} $project_dir] $val] 0 end]

            set tcldct [dict replace $tcldct $key $val]
        }

        return $tcldct
    }

    # Import source files into the Vivado project
    proc add_sources {sources import_srcs} {
        foreach fileset [dict keys $sources] {
            # Ignore the "license" key.
            if {$fileset == "license"} {
                continue
            }

            set fset [dict get $sources $fileset]
            if {[string trim $fset] != ""} {
                if {$import_srcs == 1} {
                    import_files -force -norecurse -fileset $fileset $fset
                } else {
                    add_files -norecurse -fileset $fileset $fset
                }
            }
        }
        validate_ip -quiet [get_ips]
    }

    proc create_new_project {proj_cfg proj proj_dir fdk_dir extra_cfg extra_files vhdl_ftype import_srcs} {
        set arista_fdk_dir [file normalize $fdk_dir]
        set project_dir    [file normalize [file dirname $proj_cfg]/..]
        set build_dir      [file normalize [file dirname $proj_dir]/..]
        
        set brd_std  [config_to_brdstd $proj_cfg]
        set fpga     [get_fpga $brd_std $arista_fdk_dir]

        create_vivado_project $fpga $proj $proj_dir

        set sources [get_sources $proj_cfg $arista_fdk_dir $project_dir $build_dir]
        add_sources $sources $import_srcs
        if {$extra_cfg != ""} {
            set my_sources [get_sources $extra_cfg $arista_fdk_dir $project_dir $build_dir]
            add_sources $my_sources $import_srcs
        }
        if {$extra_files != ""} {
            add_sources $extra_files $import_srcs
        }
        if {$vhdl_ftype != ""} {
            set_property "file_type" $vhdl_ftype [get_files {*.vhd *.vhdl}]
        }
    }
}
