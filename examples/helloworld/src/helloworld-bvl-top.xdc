#-------------------------------------------------------------------------------
#- Copyright (c) 2026 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Maintainers:
#-   fdk-support@arista.com
#-
#- Description:
#-   The helloworld example constraints for BVL-series board standards.
#-
#-   Licensed under BSD 3-clause license:
#-     https://opensource.org/licenses/BSD-3-Clause
#-
#- Tags:
#-   license-bsd-3-clause
#-
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#- Clock Definitions
#-------------------------------------------------------------------------------


create_generated_clock -name pcie_usr_clk  [get_pins -hier -filter {NAME =~*u_bvl_cips/versal_cips_0/inst/cpm_0/inst/CPM_INST/CPM5RCLK0INT0}]

set_false_path -from [get_clocks *] -to [get_pins -hier -filter {NAME =~ *g_sync[0]*.fdce_i/dffe_i/D}]
set_false_path -from [get_clocks *] -to [get_pins -hier -filter {NAME =~ *g_sync*.fdce_i/dffe_i/CLR}]
set_false_path -from [get_clocks *] -to [get_pins -hier -filter {NAME =~ *g_sync[0]*.fdpe_i/dffe_i/D}]
set_false_path -from [get_clocks *] -to [get_pins -hier -filter {NAME =~ *g_sync*.fdpe_i/dffe_i/PRE}]

set_property IO_BUFFER_TYPE NONE [get_ports gt_tx*]

