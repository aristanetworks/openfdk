#-------------------------------------------------------------------------------
#- Copyright (c) 2019 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Maintainers:
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

    # Get a dict of the project configuration
    proc get_proj_cfg {jfile arista_fdk_dir project_dir build_dir} {
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

    # Create a Vivado project named project in directory $proj_dir for FPGA $fpga
    proc create_vivado_project {proj_cfg proj_dir fpga} {
        create_project -force project $proj_dir -part $fpga
        set_property default_lib work [current_project]

        foreach cfg [dict keys $proj_cfg] {
            if {$cfg == "properties"} {
                set pset [dict get $proj_cfg $cfg]
                foreach p [dict keys $pset] {
                    if {$p == "target_language"} {
                        set_property target_language [dict get $pset $p] [current_project]
                    }
                    if {$p == "top"} {
                        set_property top [dict get $pset $p] [current_fileset]
                    }
                    if {$p == "verilog_define"} {
                        set_property verilog_define [dict get $pset $p] [get_filesets sources_1]
                    }
                }
            }
        }
    }

    # Import source files into the Vivado project
    proc add_sources {sources build_dir import_srcs} {
        foreach fileset [dict keys $sources] {
            # Ignore the "license" key.
            if {$fileset == "license" || $fileset == "properties"} {
                continue
            }

            set fset [dict get $sources $fileset]
            if {[string trim $fset] != ""} {
                if {$fileset == "ip_cores"} {
                    foreach core $fset {
                        import_ipcores $build_dir $core
                    }
                } else {
                    if {$import_srcs == 1} {
                        import_files -force -norecurse -fileset $fileset $fset
                    } else {
                        add_files -norecurse -fileset $fileset $fset
                    }
                }
            }
        }

        validate_ip -quiet [get_ips]
        set_property -quiet file_type "SystemVerilog" [get_files {*.sv *.v}]
        set_property -quiet file_type "VHDL 2008" [get_files {*.vhd}]
    }

    proc create_new_project {proj_cfg proj proj_dir fdk_dir extra_files import_srcs} {
        set_param general.maxThreads 1

        set arista_fdk_dir    [file normalize $fdk_dir]
        set project_dir       [file normalize [file dirname $proj_cfg]/..]
        set build_dir         [file normalize [file dirname $proj_dir]/..]

        set brd_std [config_to_brdstd $proj_cfg]
        set fpga    [get_fpga $brd_std $arista_fdk_dir]

        set project_config [get_proj_cfg $proj_cfg $arista_fdk_dir $project_dir $build_dir]
        create_vivado_project $project_config $proj_dir $fpga

        add_sources $project_config $build_dir $import_srcs
        if {$extra_files != ""} {
            add_sources $extra_files $build_dir $import_srcs
        }
    }

    proc import_ipcores {build_dir ip_file} {
        # Extract IP file info
        set ip_list  [split $ip_file "/"]
        set ip_fname [lindex $ip_list end]
        set ip_name  [lindex [split $ip_fname "."] 0]
        set ip_type  [lindex [split $ip_fname "."] end]
        
        set ip_dir    [file normalize [file dirname $ip_file]]
        set part_dir  [file dirname $ip_dir]
        set part_name [file tail $part_dir] 
        # --------------------------

        # Now define the generation path using the real part name
        set gen_dir    [file normalize [file join $build_dir generated_ip]]
        set ip_gen_dir [file join $gen_dir $part_name $ip_name]

        # set generated ip directory
        file mkdir $gen_dir
        file mkdir [file join $gen_dir $part_name]
        file mkdir $ip_gen_dir

        if {$ip_type == "tcl"} {
            # ipcore_dir is the -dir argument passed to create_ip inside the TCL.
            # Keep it as ip_gen_dir (gen_dir/part_name/ip_name) so that IPs which
            # use -dir as a direct output directory (e.g. DDR4 MIG, which places
            # ip_name.xci and custom_parts_ddr4.csv directly in -dir) still find
            # their generated files at $ipcore_dir/*.
            #
            # IPs that add a module subdirectory under -dir (e.g. sem_ultra, which
            # creates $dir/$name/$name.xci) would double-nest on rebuild because
            # ip_gen_dir already ends in ip_name.  Fix: pre-clean that subdirectory
            # so create_ip always starts from a clean slate.
            set ipcore_dir $ip_gen_dir
            set stale_subdir [file join $ip_gen_dir $ip_name]
            if {[file exists $stale_subdir]} {
                if {[catch {file delete -force $stale_subdir} del_err]} {
                    puts "WARNING: import_ipcores: could not delete stale subdir $stale_subdir: $del_err"
                }
            }
            # Wrap in catch: parallel builds sharing ip_gen_dir can race on
            # create_ip (one instance deletes stale_subdir while another is
            # writing into it).  A failure here must not leave Vivado in a
            # persistent error state that kills all subsequent create_ip calls.
            if {[catch {source $ip_file -notrace} src_err]} {
                puts "WARNING: import_ipcores: source $ip_file failed: $src_err"
                puts "WARNING: Will attempt to use any XCI already written to disk."
            }

            set gen_xci_files [glob -nocomplain -types f \
                [file join $ip_gen_dir ** "$ip_name.xci"]]

            foreach gen_xci $gen_xci_files {
                set dst_xci [file join $ip_dir "$ip_name.xci"]
                if {[file exists $gen_xci]} {
                    # Wrap in catch: parallel builds can race on stale_subdir
                    # deletion — one process deletes the directory (and the
                    # XCI inside it) between our [file exists] check and the
                    # copy.  The other process will regenerate and copy it, so
                    # a warning here is safe.
                    if {[catch {file copy -force $gen_xci $dst_xci} copy_err]} {
                        puts "WARNING: import_ipcores: copy $ip_name.xci failed: $copy_err"
                        puts "WARNING: Will use any XCI already at destination."
                    } else {
                        puts "INFO: Force-copied $ip_name.xci to $ip_dir"
                    }
                }
            }
        } else {
            file copy -force $ip_file [file join $ip_gen_dir $ip_fname]
            import_files -force -norecurse -fileset "sources_1" [file join $ip_gen_dir $ip_fname]
        }
    }
}
