#-------------------------------------------------------------------------------
#- Copyright (c) 2020 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Author:
#-   fdk-support@arista.com
#-
#- Description:
#-   Timestamp Core Constraints File
#-
#- Tags:
#-   license-arista-fdk-agreement
#-   license-bsd-3-clause
#-
#-------------------------------------------------------------------------------

# Over-ride default setting from board_constraints file
create_clock -period 100.000 -name ts_clk [get_ports ts_clk_in]

create_generated_clock -name clk_500M_int [get_pins -hier -filter {NAME =~ */timing_controller_i/clk_gen_i/clk_500M_from_int_i/CLKOUT0}]
create_generated_clock -name clk_500M_ext [get_pins -hier -filter {NAME =~ */timing_controller_i/clk_gen_i/*clk_500M_from_ext_i/CLKOUT0}]
set_property CLOCK_DEDICATED_ROUTE FALSE  [get_nets -hier -filter {NAME =~ */timing_controller_i/clk_gen_i/clk_500M_i}]

set_clock_groups -physically_exclusive -group [get_clocks clk_500M_int] -group [get_clocks clk_500M_ext]
set_clock_groups -asynchronous -group [get_clocks refclk_user_0 -include_generated_clocks]
set_clock_groups -asynchronous -group [get_clocks refclk_25] -group [get_clocks refclk_user_0]

set_clock_groups -asynchronous -group [get_clocks refclk_25] -group [get_clocks clk_500M_int]
set_clock_groups -asynchronous -group [get_clocks refclk_25] -group [get_clocks clk_500M_ext]
set_clock_groups -asynchronous -group [get_clocks refclk_25] -group [get_pins -hier -filter {NAME =~ */timing_controller_i/clk_gen_i/clk_500M_mux_i/S0}]

