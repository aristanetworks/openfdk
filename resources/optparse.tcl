#-------------------------------------------------------------------------------
#- Copyright (c) 2020 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Maintainers:
#-   fdk-support@arista.com
#-
#- Description:
#-   Simple Tcl option parsing using the cmdline package
#-
#- Tags:
#-   license-arista-fdk-agreement
#-   license-bsd-3-clause
#-
#-------------------------------------------------------------------------------

# Example usage:
#
#   source optparse.tcl
#   set usage "An example script"
#   set options {}
#
#   # Create a required option with argument
#   lappend options [optparse::create_option_with_arg    aardvark "Help, an aardvark" $optparse::REQUIRED     ""]
#
#   # Create an optional option with argument
#   lappend options [optparse::create_option_with_arg    bear     "Help, a bear"      $optparse::NOT_REQUIRED "bear"]
#
#   # Create an option without argument
#   lappend options [optparse::create_option_without_arg chicken  "Help, a chicken"]
#
#   # Parse options
#   array set opts [optparse::parse_options $options $usage]
#
#   # Print options
#   parray opts
#
#   # Access each option
#   set aardvark $array(aardvark) # default value ""
#   set bear     $array(bear)     # default value "bear"
#   set chicken  $array(chicken)  # default value 0

namespace eval optparse {
    package require cmdline

    variable REQUIRED true
    variable OPTIONAL false

    # Create an option with argument in the format
    #   $option.arg $default "Required|Optional: $help \[default\]"
    # Add "[default]" to the end of help messages for options with arguments
    # because cmdline prints out the default value at the end, e.g.
    # an option
    #   opt.arg "foo" "Required: A help message \[default\]"
    # will result in the help message
    #   -opt value    Required: A help message [default] <foo>.
    proc create_option_with_arg {name help required {default ""}} {
        set optstring [list $name.arg $default "[expr {$required ? {Required} : {Optional}}]: $help \[default\]"]
        return $optstring
    }

    # Create an option without argument in the format
    #   <option> "Optional: <help>".
    proc create_option_without_arg {name help} {
        set optstring [list $name "Optional: $help"]
        return $optstring
    }

    proc parse_options {optlist usage} {
        if {[catch {set opts [cmdline::getoptions ::argv $optlist $usage]}]} {
            _print_help $optlist $usage
            _print_error "Invalid options"
        }

        # Make sure that required options are present
        foreach optstring $optlist {
            set opt [_optstring_get_name $optstring]
            if {[_optstring_is_required $optstring]} {
                set val [dict get $opts $opt]
                if {[string trim $val] == ""} {
                    _print_help $optlist $usage
                    _print_error "Option -$opt is required"
                }
            }
        }
        return $opts
    }

    proc _optstring_get_name {optstring} {
        return [regsub {(\w+)(\.arg)?} [lindex $optstring 0] {\1}]
    }

    proc _optstring_is_required {optstring} {
        return [string match "Required: *" [lindex $optstring end]]
    }

    proc _print_help {optlist usage} {
        puts [cmdline::usage $optlist $usage]
    }

    proc _print_error {msg} {
        error "ERROR: $msg"
    }
}
