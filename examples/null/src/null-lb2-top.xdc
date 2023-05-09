#-------------------------------------------------------------------------------
#- Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Author:
#-   fdk-support@arista.com
#-
#- Description:
#-   Constraints for the Null example on the lb2 board standard.
#-
#-   Licensed under BSD 3-clause license:
#-     https://opensource.org/licenses/BSD-3-Clause
#-
#- Tags:
#-   license-bsd-3-clause
#-
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#- Timing Exceptions
#-------------------------------------------------------------------------------

set_clock_groups -asynchronous -group [get_clocks refclk_25] -group [get_clocks sem_clk]
set_clock_groups -asynchronous -group [get_clocks refclk_25] -group [get_clocks i2c_clk_*]

set_false_path -from [get_pins arista_sysctl_i/gen_sem.sem_i/g_icap.u_icap/CLK] -to [get_pins -hier -filter {NAME =~ arista_sysctl_i/gen_sem.sem_i/*/controller_synchro_icap_prerror/sync_a/D}]
set_false_path -from [get_pins arista_sysctl_i/gen_sem.sem_i/g_icap.u_icap/CLK] -to [get_pins -hier -filter {NAME =~ arista_sysctl_i/gen_sem.sem_i/*/controller_synchro_icap_prdone/sync_a/D}]
set_false_path -from [get_pins arista_sysctl_i/gen_sem.sem_i/g_icap.u_icap/CLK] -to [get_pins -hier -filter {NAME =~ arista_sysctl_i/gen_sem.sem_i/*/controller_synchro_icap_avail/sync_a/D}]

#-------------------------------------------------------------------------------
#- Location Constraints
#-------------------------------------------------------------------------------

create_pblock sem
resize_pblock [get_pblocks sem] -add {SLICE_X151Y300:SLICE_X155Y329}
resize_pblock [get_pblocks sem] -add {RAMB36_X10Y60:RAMB36_X10Y65}
resize_pblock [get_pblocks sem] -add {RAMB18_X10Y120:RAMB18_X10Y131}
resize_pblock [get_pblocks sem] -add {DSP48E2_X17Y120:DSP48E2_X17Y131}

add_cells_to_pblock -pblock sem -cells [get_cells arista_sysctl_i/gen_sem.sem_i/*]
remove_cells_from_pblock sem [get_cells -hier -filter {NAME =~ arista_sysctl_i/gen_sem.sem_i/*u_sem_ip/inst/controller/slr*_fecc_*_reg*}]
remove_cells_from_pblock sem [get_cells arista_sysctl_i/gen_sem.sem_i/g_icap.u_icap]
remove_cells_from_pblock sem [get_cells arista_sysctl_i/gen_sem.sem_i/g_slr[0].g_ecc.u_frame_ecc]
remove_cells_from_pblock sem [get_cells arista_sysctl_i/gen_sem.sem_i/g_slr[1].g_ecc.u_frame_ecc]
remove_cells_from_pblock sem [get_cells arista_sysctl_i/gen_sem.sem_i/g_slr[2].g_ecc.u_frame_ecc]

set_property LOC CONFIG_SITE_X0Y1 [get_cells arista_sysctl_i/gen_sem.sem_i/g_icap.u_icap]
set_property LOC CONFIG_SITE_X0Y0 [get_cells arista_sysctl_i/gen_sem.sem_i/g_slr[0].g_ecc.u_frame_ecc]
set_property LOC CONFIG_SITE_X0Y1 [get_cells arista_sysctl_i/gen_sem.sem_i/g_slr[1].g_ecc.u_frame_ecc]
set_property LOC CONFIG_SITE_X0Y2 [get_cells arista_sysctl_i/gen_sem.sem_i/g_slr[2].g_ecc.u_frame_ecc]

#-------------------------------------------------------------------------------
#- Physical Constraints
#- (Can be in a separate file to the above timing constraints)
#-------------------------------------------------------------------------------

set_property IO_BUFFER_TYPE NONE [get_ports gt_tx_*]
set_property IO_BUFFER_TYPE NONE [get_ports pcie_tx*]
