#-------------------------------------------------------------------------------
#- Copyright (c) 2017-2022 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Author:
#-   fdk-support@arista.com
#-
#- Description:
#-   Specific Board Standard Constraints
#-
#-   Licensed under BSD 3-clause license:
#-     https://opensource.org/licenses/BSD-3-Clause
#-
#- Tags:
#-   license-bsd-3-clause
#-
#-------------------------------------------------------------------------------


################################################################################
## Configuration Assertions
################################################################################


# The VCCO voltage is set to 1.8 V on bank 0
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS         GND [current_design]

# Compress the bitstream
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN DIV-1 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]


################################################################################
## Timing Assertions
##
## Arranged in the following order:
## - Primary clocks
## - Virtual clocks
## - Generated clocks
## - Clock groups
## - Input and Output delay constraints
################################################################################


create_clock -period 12.500   -name emcclk        [get_ports emcclk]

create_clock -period 8.000    -name ts_clk        [get_ports ts_clk_in]

create_clock -period 6.400    -name refclk_user_0 [get_ports {refclk_user_p[0]}]
create_clock -period 3.103    -name refclk_user_1 [get_ports {refclk_user_p[1]}]
create_clock -period 3.103    -name refclk_user_2 [get_ports {refclk_user_p[2]}]

create_clock -period 6.400    -name gt_refclk_0   [get_ports {gt_refclk_p[0]}]
create_clock -period 8.000    -name gt_refclk_1   [get_ports {gt_refclk_p[1]}]
create_clock -period 6.400    -name gt_refclk_2   [get_ports {gt_refclk_p[2]}]
create_clock -period 8.000    -name gt_refclk_3   [get_ports {gt_refclk_p[3]}]
create_clock -period 10.000   -name gt_refclk_4   [get_ports {gt_refclk_p[4]}]

create_clock -period 10.000   -name pcie_refclk   [get_ports pcie_refclk_p]

create_clock -period 2500.000 -name i2c_clk_0     [get_ports {i2c_scl[0]}]
create_clock -period 2500.000 -name i2c_clk_1     [get_ports {i2c_scl[1]}]

create_generated_clock -name sem_clk -source [get_pins bufg_sem_clock/I] -divide_by 2 [get_pins bufg_sem_clock/O]
create_generated_clock -name refclk_25 [get_pins -hier -filter {NAME =~ arista_sysctl_i/refclk_pll_i/*CLKOUT0}]
create_generated_clock -name refclk_50 [get_pins -hier -filter {NAME =~ arista_sysctl_i/refclk_pll_i/*CLKOUT1}]


################################################################################
## Timing Exceptions
##
## Arranged in the following order:
## - Primary clocks
## - False paths
## - Max delay/min delay
## - Multicycle paths
## - Case analysis
## - Disable Timing
################################################################################



set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets ibuf_emcclk/O]

set_false_path -from [get_ports pcie_perst_n]


################################################################################
## Physical Constraints
## (Can be in a separate file to the above timing constraints)
################################################################################



set_property PACKAGE_PIN AL27 [get_ports emcclk]
set_property IOSTANDARD LVCMOS18 [get_ports emcclk]

set_property PACKAGE_PIN BB9  [get_ports ts_clk_in]
set_property IOSTANDARD LVCMOS18 [get_ports ts_clk_in]

set_property PACKAGE_PIN BA9 [get_ports pps_in_n]
set_property IOSTANDARD LVCMOS18 [get_ports pps_in_n]

set_property PACKAGE_PIN AY13 [get_ports {refclk_user_p[0]}]
set_property PACKAGE_PIN BA13 [get_ports {refclk_user_n[0]}]
set_property PACKAGE_PIN BA35 [get_ports {refclk_user_p[1]}]
set_property PACKAGE_PIN BB35 [get_ports {refclk_user_n[1]}]
set_property PACKAGE_PIN AV19 [get_ports {refclk_user_p[2]}]
set_property PACKAGE_PIN AW19 [get_ports {refclk_user_n[2]}]
set_property IOSTANDARD LVDS [get_ports {refclk_user_p[*]}]
set_property DIFF_TERM_ADV TERM_NONE [get_ports {refclk_user_p[*]}]

set_property PACKAGE_PIN AM11 [get_ports {gt_refclk_p[0]}]
set_property PACKAGE_PIN AM10 [get_ports {gt_refclk_n[0]}]
set_property PACKAGE_PIN AK11 [get_ports {gt_refclk_p[1]}]
set_property PACKAGE_PIN AK10 [get_ports {gt_refclk_n[1]}]
set_property PACKAGE_PIN M11  [get_ports {gt_refclk_p[2]}]
set_property PACKAGE_PIN M10  [get_ports {gt_refclk_n[2]}]
set_property PACKAGE_PIN K11  [get_ports {gt_refclk_p[3]}]
set_property PACKAGE_PIN K10  [get_ports {gt_refclk_n[3]}]
set_property PACKAGE_PIN T11  [get_ports {gt_refclk_p[4]}]
set_property PACKAGE_PIN T10  [get_ports {gt_refclk_n[4]}]
set_property PACKAGE_PIN AN4  [get_ports {gt_rx_p[1]}]
set_property PACKAGE_PIN AN3  [get_ports {gt_rx_n[1]}]
set_property PACKAGE_PIN AN9  [get_ports {gt_tx_p[1]}]
set_property PACKAGE_PIN AN8  [get_ports {gt_tx_n[1]}]
set_property PACKAGE_PIN AM2  [get_ports {gt_rx_p[2]}]
set_property PACKAGE_PIN AM1  [get_ports {gt_rx_n[2]}]
set_property PACKAGE_PIN AM7  [get_ports {gt_tx_p[2]}]
set_property PACKAGE_PIN AM6  [get_ports {gt_tx_n[2]}]
set_property PACKAGE_PIN AL4  [get_ports {gt_rx_p[3]}]
set_property PACKAGE_PIN AL3  [get_ports {gt_rx_n[3]}]
set_property PACKAGE_PIN AL9  [get_ports {gt_tx_p[3]}]
set_property PACKAGE_PIN AL8  [get_ports {gt_tx_n[3]}]
set_property PACKAGE_PIN AK2  [get_ports {gt_rx_p[4]}]
set_property PACKAGE_PIN AK1  [get_ports {gt_rx_n[4]}]
set_property PACKAGE_PIN AK7  [get_ports {gt_tx_p[4]}]
set_property PACKAGE_PIN AK6  [get_ports {gt_tx_n[4]}]
set_property PACKAGE_PIN AJ4  [get_ports {gt_rx_p[5]}]
set_property PACKAGE_PIN AJ3  [get_ports {gt_rx_n[5]}]
set_property PACKAGE_PIN AJ9  [get_ports {gt_tx_p[5]}]
set_property PACKAGE_PIN AJ8  [get_ports {gt_tx_n[5]}]
set_property PACKAGE_PIN AH2  [get_ports {gt_rx_p[6]}]
set_property PACKAGE_PIN AH1  [get_ports {gt_rx_n[6]}]
set_property PACKAGE_PIN AH7  [get_ports {gt_tx_p[6]}]
set_property PACKAGE_PIN AH6  [get_ports {gt_tx_n[6]}]
set_property PACKAGE_PIN AG4  [get_ports {gt_rx_p[7]}]
set_property PACKAGE_PIN AG3  [get_ports {gt_rx_n[7]}]
set_property PACKAGE_PIN AG9  [get_ports {gt_tx_p[7]}]
set_property PACKAGE_PIN AG8  [get_ports {gt_tx_n[7]}]
set_property PACKAGE_PIN AF2  [get_ports {gt_rx_p[8]}]
set_property PACKAGE_PIN AF1  [get_ports {gt_rx_n[8]}]
set_property PACKAGE_PIN AF7  [get_ports {gt_tx_p[8]}]
set_property PACKAGE_PIN AF6  [get_ports {gt_tx_n[8]}]
set_property PACKAGE_PIN AE4  [get_ports {gt_rx_p[9]}]
set_property PACKAGE_PIN AE3  [get_ports {gt_rx_n[9]}]
set_property PACKAGE_PIN AE9  [get_ports {gt_tx_p[9]}]
set_property PACKAGE_PIN AE8  [get_ports {gt_tx_n[9]}]
set_property PACKAGE_PIN AD2  [get_ports {gt_rx_p[10]}]
set_property PACKAGE_PIN AD1  [get_ports {gt_rx_n[10]}]
set_property PACKAGE_PIN AD7  [get_ports {gt_tx_p[10]}]
set_property PACKAGE_PIN AD6  [get_ports {gt_tx_n[10]}]
set_property PACKAGE_PIN AC4  [get_ports {gt_rx_p[11]}]
set_property PACKAGE_PIN AC3  [get_ports {gt_rx_n[11]}]
set_property PACKAGE_PIN AC9  [get_ports {gt_tx_p[11]}]
set_property PACKAGE_PIN AC8  [get_ports {gt_tx_n[11]}]
set_property PACKAGE_PIN AB2  [get_ports {gt_rx_p[12]}]
set_property PACKAGE_PIN AB1  [get_ports {gt_rx_n[12]}]
set_property PACKAGE_PIN AB7  [get_ports {gt_tx_p[12]}]
set_property PACKAGE_PIN AB6  [get_ports {gt_tx_n[12]}]
set_property PACKAGE_PIN AA4  [get_ports {gt_rx_p[13]}]
set_property PACKAGE_PIN AA3  [get_ports {gt_rx_n[13]}]
set_property PACKAGE_PIN AA9  [get_ports {gt_tx_p[13]}]
set_property PACKAGE_PIN AA8  [get_ports {gt_tx_n[13]}]
set_property PACKAGE_PIN Y2   [get_ports {gt_rx_p[14]}]
set_property PACKAGE_PIN Y1   [get_ports {gt_rx_n[14]}]
set_property PACKAGE_PIN Y7   [get_ports {gt_tx_p[14]}]
set_property PACKAGE_PIN Y6   [get_ports {gt_tx_n[14]}]
set_property PACKAGE_PIN U4   [get_ports {inter_gt_rx_p[1]}]
set_property PACKAGE_PIN U3   [get_ports {inter_gt_rx_n[1]}]
set_property PACKAGE_PIN U9   [get_ports {inter_gt_tx_p[1]}]
set_property PACKAGE_PIN U8   [get_ports {inter_gt_tx_n[1]}]
set_property PACKAGE_PIN T2   [get_ports {inter_gt_rx_p[2]}]
set_property PACKAGE_PIN T1   [get_ports {inter_gt_rx_n[2]}]
set_property PACKAGE_PIN T7   [get_ports {inter_gt_tx_p[2]}]
set_property PACKAGE_PIN T6   [get_ports {inter_gt_tx_n[2]}]
set_property PACKAGE_PIN R4   [get_ports {inter_gt_rx_p[3]}]
set_property PACKAGE_PIN R3   [get_ports {inter_gt_rx_n[3]}]
set_property PACKAGE_PIN R9   [get_ports {inter_gt_tx_p[3]}]
set_property PACKAGE_PIN R8   [get_ports {inter_gt_tx_n[3]}]
set_property PACKAGE_PIN P2   [get_ports {inter_gt_rx_p[4]}]
set_property PACKAGE_PIN P1   [get_ports {inter_gt_rx_n[4]}]
set_property PACKAGE_PIN P7   [get_ports {inter_gt_tx_p[4]}]
set_property PACKAGE_PIN P6   [get_ports {inter_gt_tx_n[4]}]
set_property PACKAGE_PIN N4   [get_ports {inter_gt_rx_p[5]}]
set_property PACKAGE_PIN N3   [get_ports {inter_gt_rx_n[5]}]
set_property PACKAGE_PIN N9   [get_ports {inter_gt_tx_p[5]}]
set_property PACKAGE_PIN N8   [get_ports {inter_gt_tx_n[5]}]
set_property PACKAGE_PIN M2   [get_ports {inter_gt_rx_p[6]}]
set_property PACKAGE_PIN M1   [get_ports {inter_gt_rx_n[6]}]
set_property PACKAGE_PIN M7   [get_ports {inter_gt_tx_p[6]}]
set_property PACKAGE_PIN M6   [get_ports {inter_gt_tx_n[6]}]
set_property PACKAGE_PIN L4   [get_ports {inter_gt_rx_p[7]}]
set_property PACKAGE_PIN L3   [get_ports {inter_gt_rx_n[7]}]
set_property PACKAGE_PIN L9   [get_ports {inter_gt_tx_p[7]}]
set_property PACKAGE_PIN L8   [get_ports {inter_gt_tx_n[7]}]
set_property PACKAGE_PIN K2   [get_ports {inter_gt_rx_p[8]}]
set_property PACKAGE_PIN K1   [get_ports {inter_gt_rx_n[8]}]
set_property PACKAGE_PIN K7   [get_ports {inter_gt_tx_p[8]}]
set_property PACKAGE_PIN K6   [get_ports {inter_gt_tx_n[8]}]
set_property PACKAGE_PIN BE8  [get_ports inter_gt_gpio]
set_property IOSTANDARD LVCMOS18 [get_ports inter_gt_gpio]
# Onboard Pulldown for inter_gt_gpio...

set_property PACKAGE_PIN AU4  [get_ports {pcie_rx_p[3]}]
set_property PACKAGE_PIN AU3  [get_ports {pcie_rx_n[3]}]
set_property PACKAGE_PIN AU9  [get_ports {pcie_tx_p[3]}]
set_property PACKAGE_PIN AU8  [get_ports {pcie_tx_n[3]}]
set_property PACKAGE_PIN AT2  [get_ports {pcie_rx_p[2]}]
set_property PACKAGE_PIN AT1  [get_ports {pcie_rx_n[2]}]
set_property PACKAGE_PIN AT7  [get_ports {pcie_tx_p[2]}]
set_property PACKAGE_PIN AT6  [get_ports {pcie_tx_n[2]}]
set_property PACKAGE_PIN AR4  [get_ports {pcie_rx_p[1]}]
set_property PACKAGE_PIN AR3  [get_ports {pcie_rx_n[1]}]
set_property PACKAGE_PIN AR9  [get_ports {pcie_tx_p[1]}]
set_property PACKAGE_PIN AR8  [get_ports {pcie_tx_n[1]}]
set_property PACKAGE_PIN AP2  [get_ports {pcie_rx_p[0]}]
set_property PACKAGE_PIN AP1  [get_ports {pcie_rx_n[0]}]
set_property PACKAGE_PIN AP7  [get_ports {pcie_tx_p[0]}]
set_property PACKAGE_PIN AP6  [get_ports {pcie_tx_n[0]}]
set_property PACKAGE_PIN AT11 [get_ports pcie_refclk_p]
set_property PACKAGE_PIN AT10 [get_ports pcie_refclk_n]
set_property PACKAGE_PIN AR26 [get_ports pcie_perst_n]
set_property PACKAGE_PIN BF8  [get_ports pcie_wake_n]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_perst_n]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_wake_n]
# Onboard Pullup for pcie_perst_n...
# Onboard Pulldown for pcie_wake_n...

# Inter-FPGA General Purpose DCI Group
set_property PACKAGE_PIN G19 [get_ports {inter_gpa_diff_gc[11]}]
set_property PACKAGE_PIN G20 [get_ports {inter_gpa_diff_gc[10]}]
set_property PACKAGE_PIN H18 [get_ports {inter_gpa_diff_gc[9]}]
set_property PACKAGE_PIN H19 [get_ports {inter_gpa_diff_gc[8]}]
set_property PACKAGE_PIN J18 [get_ports {inter_gpa_diff_gc[7]}]
set_property PACKAGE_PIN K18 [get_ports {inter_gpa_diff_gc[6]}]
set_property PACKAGE_PIN F15 [get_ports {inter_gpa_diff_gc[5]}]
set_property PACKAGE_PIN G15 [get_ports {inter_gpa_diff_gc[4]}]
set_property PACKAGE_PIN F14 [get_ports {inter_gpa_diff_gc[3]}]
set_property PACKAGE_PIN G14 [get_ports {inter_gpa_diff_gc[2]}]
set_property PACKAGE_PIN H14 [get_ports {inter_gpa_diff_gc[1]}]
set_property PACKAGE_PIN J14 [get_ports {inter_gpa_diff_gc[0]}]

set_property PACKAGE_PIN A20 [get_ports {inter_gpa_diff[79]}]
set_property PACKAGE_PIN B20 [get_ports {inter_gpa_diff[78]}]
set_property PACKAGE_PIN A19 [get_ports {inter_gpa_diff[77]}]
set_property PACKAGE_PIN B19 [get_ports {inter_gpa_diff[76]}]
set_property PACKAGE_PIN C18 [get_ports {inter_gpa_diff[75]}]
set_property PACKAGE_PIN D18 [get_ports {inter_gpa_diff[74]}]
set_property PACKAGE_PIN B21 [get_ports {inter_gpa_diff[73]}]
set_property PACKAGE_PIN C21 [get_ports {inter_gpa_diff[72]}]
set_property PACKAGE_PIN D20 [get_ports {inter_gpa_diff[71]}]
set_property PACKAGE_PIN D21 [get_ports {inter_gpa_diff[70]}]
set_property PACKAGE_PIN C19 [get_ports {inter_gpa_diff[69]}]
set_property PACKAGE_PIN D19 [get_ports {inter_gpa_diff[68]}]
set_property PACKAGE_PIN F17 [get_ports {inter_gpa_diff[67]}]
set_property PACKAGE_PIN F18 [get_ports {inter_gpa_diff[66]}]
set_property PACKAGE_PIN E20 [get_ports {inter_gpa_diff[65]}]
set_property PACKAGE_PIN E21 [get_ports {inter_gpa_diff[64]}]
set_property PACKAGE_PIN E17 [get_ports {inter_gpa_diff[63]}]
set_property PACKAGE_PIN E18 [get_ports {inter_gpa_diff[62]}]
set_property PACKAGE_PIN F19 [get_ports {inter_gpa_diff[61]}]
set_property PACKAGE_PIN F20 [get_ports {inter_gpa_diff[60]}]
set_property PACKAGE_PIN H21 [get_ports {inter_gpa_diff[59]}]
set_property PACKAGE_PIN J21 [get_ports {inter_gpa_diff[58]}]
set_property PACKAGE_PIN K20 [get_ports {inter_gpa_diff[57]}]
set_property PACKAGE_PIN L20 [get_ports {inter_gpa_diff[56]}]
set_property PACKAGE_PIN L18 [get_ports {inter_gpa_diff[55]}]
set_property PACKAGE_PIN L19 [get_ports {inter_gpa_diff[54]}]
set_property PACKAGE_PIN K17 [get_ports {inter_gpa_diff[53]}]
set_property PACKAGE_PIN L17 [get_ports {inter_gpa_diff[52]}]
set_property PACKAGE_PIN M21 [get_ports {inter_gpa_diff[51]}]
set_property PACKAGE_PIN N21 [get_ports {inter_gpa_diff[50]}]
set_property PACKAGE_PIN P20 [get_ports {inter_gpa_diff[49]}]
set_property PACKAGE_PIN R20 [get_ports {inter_gpa_diff[48]}]
set_property PACKAGE_PIN N19 [get_ports {inter_gpa_diff[47]}]
set_property PACKAGE_PIN P19 [get_ports {inter_gpa_diff[46]}]
set_property PACKAGE_PIN M19 [get_ports {inter_gpa_diff[45]}]
set_property PACKAGE_PIN M20 [get_ports {inter_gpa_diff[44]}]
set_property PACKAGE_PIN N18 [get_ports {inter_gpa_diff[43]}]
set_property PACKAGE_PIN P18 [get_ports {inter_gpa_diff[42]}]
set_property PACKAGE_PIN M17 [get_ports {inter_gpa_diff[41]}]
set_property PACKAGE_PIN N17 [get_ports {inter_gpa_diff[40]}]
set_property PACKAGE_PIN A17 [get_ports {inter_gpa_diff[39]}]
set_property PACKAGE_PIN B17 [get_ports {inter_gpa_diff[38]}]
set_property PACKAGE_PIN B16 [get_ports {inter_gpa_diff[37]}]
set_property PACKAGE_PIN C16 [get_ports {inter_gpa_diff[36]}]
set_property PACKAGE_PIN A15 [get_ports {inter_gpa_diff[35]}]
set_property PACKAGE_PIN B15 [get_ports {inter_gpa_diff[34]}]
set_property PACKAGE_PIN A13 [get_ports {inter_gpa_diff[33]}]
set_property PACKAGE_PIN A14 [get_ports {inter_gpa_diff[32]}]
set_property PACKAGE_PIN B14 [get_ports {inter_gpa_diff[31]}]
set_property PACKAGE_PIN C14 [get_ports {inter_gpa_diff[30]}]
set_property PACKAGE_PIN C13 [get_ports {inter_gpa_diff[29]}]
set_property PACKAGE_PIN D13 [get_ports {inter_gpa_diff[28]}]
set_property PACKAGE_PIN D16 [get_ports {inter_gpa_diff[27]}]
set_property PACKAGE_PIN E16 [get_ports {inter_gpa_diff[26]}]
set_property PACKAGE_PIN D15 [get_ports {inter_gpa_diff[25]}]
set_property PACKAGE_PIN E15 [get_ports {inter_gpa_diff[24]}]
set_property PACKAGE_PIN G16 [get_ports {inter_gpa_diff[23]}]
set_property PACKAGE_PIN G17 [get_ports {inter_gpa_diff[22]}]
set_property PACKAGE_PIN E13 [get_ports {inter_gpa_diff[21]}]
set_property PACKAGE_PIN F13 [get_ports {inter_gpa_diff[20]}]
set_property PACKAGE_PIN H16 [get_ports {inter_gpa_diff[19]}]
set_property PACKAGE_PIN H17 [get_ports {inter_gpa_diff[18]}]
set_property PACKAGE_PIN H13 [get_ports {inter_gpa_diff[17]}]
set_property PACKAGE_PIN J13 [get_ports {inter_gpa_diff[16]}]
set_property PACKAGE_PIN K15 [get_ports {inter_gpa_diff[15]}]
set_property PACKAGE_PIN K16 [get_ports {inter_gpa_diff[14]}]
set_property PACKAGE_PIN K13 [get_ports {inter_gpa_diff[13]}]
set_property PACKAGE_PIN L13 [get_ports {inter_gpa_diff[12]}]
set_property PACKAGE_PIN M16 [get_ports {inter_gpa_diff[11]}]
set_property PACKAGE_PIN N16 [get_ports {inter_gpa_diff[10]}]
set_property PACKAGE_PIN L14 [get_ports {inter_gpa_diff[9]}]
set_property PACKAGE_PIN M14 [get_ports {inter_gpa_diff[8]}]
set_property PACKAGE_PIN P16 [get_ports {inter_gpa_diff[7]}]
set_property PACKAGE_PIN R16 [get_ports {inter_gpa_diff[6]}]
set_property PACKAGE_PIN P15 [get_ports {inter_gpa_diff[5]}]
set_property PACKAGE_PIN R15 [get_ports {inter_gpa_diff[4]}]
set_property PACKAGE_PIN N14 [get_ports {inter_gpa_diff[3]}]
set_property PACKAGE_PIN P14 [get_ports {inter_gpa_diff[2]}]
set_property PACKAGE_PIN N13 [get_ports {inter_gpa_diff[1]}]
set_property PACKAGE_PIN P13 [get_ports {inter_gpa_diff[0]}]

set_property PACKAGE_PIN A18 [get_ports {inter_gpa_gpio[5]}]
set_property PACKAGE_PIN G21 [get_ports {inter_gpa_gpio[4]}]
set_property PACKAGE_PIN K21 [get_ports {inter_gpa_gpio[3]}]
set_property PACKAGE_PIN C17 [get_ports {inter_gpa_gpio[2]}]
set_property PACKAGE_PIN D14 [get_ports {inter_gpa_gpio[1]}]
set_property PACKAGE_PIN L15 [get_ports {inter_gpa_gpio[0]}]

# Inter-FPGA General Purpose DCI Group
set_property PACKAGE_PIN G27 [get_ports {inter_gpa_diff_gc[23]}]
set_property PACKAGE_PIN G26 [get_ports {inter_gpa_diff_gc[22]}]
set_property PACKAGE_PIN H26 [get_ports {inter_gpa_diff_gc[21]}]
set_property PACKAGE_PIN J26 [get_ports {inter_gpa_diff_gc[20]}]
set_property PACKAGE_PIN H28 [get_ports {inter_gpa_diff_gc[19]}]
set_property PACKAGE_PIN H27 [get_ports {inter_gpa_diff_gc[18]}]
set_property PACKAGE_PIN D36 [get_ports {inter_gpa_diff_gc[17]}]
set_property PACKAGE_PIN E36 [get_ports {inter_gpa_diff_gc[16]}]
set_property PACKAGE_PIN C37 [get_ports {inter_gpa_diff_gc[15]}]
set_property PACKAGE_PIN C36 [get_ports {inter_gpa_diff_gc[14]}]
set_property PACKAGE_PIN D38 [get_ports {inter_gpa_diff_gc[13]}]
set_property PACKAGE_PIN E38 [get_ports {inter_gpa_diff_gc[12]}]

set_property PACKAGE_PIN A30 [get_ports {inter_gpa_diff[159]}]
set_property PACKAGE_PIN B30 [get_ports {inter_gpa_diff[158]}]
set_property PACKAGE_PIN A29 [get_ports {inter_gpa_diff[157]}]
set_property PACKAGE_PIN B29 [get_ports {inter_gpa_diff[156]}]
set_property PACKAGE_PIN A28 [get_ports {inter_gpa_diff[155]}]
set_property PACKAGE_PIN A27 [get_ports {inter_gpa_diff[154]}]
set_property PACKAGE_PIN D30 [get_ports {inter_gpa_diff[153]}]
set_property PACKAGE_PIN E30 [get_ports {inter_gpa_diff[152]}]
set_property PACKAGE_PIN C29 [get_ports {inter_gpa_diff[151]}]
set_property PACKAGE_PIN D29 [get_ports {inter_gpa_diff[150]}]
set_property PACKAGE_PIN B27 [get_ports {inter_gpa_diff[149]}]
set_property PACKAGE_PIN C27 [get_ports {inter_gpa_diff[148]}]
set_property PACKAGE_PIN D28 [get_ports {inter_gpa_diff[147]}]
set_property PACKAGE_PIN E28 [get_ports {inter_gpa_diff[146]}]
set_property PACKAGE_PIN E27 [get_ports {inter_gpa_diff[145]}]
set_property PACKAGE_PIN F27 [get_ports {inter_gpa_diff[144]}]
set_property PACKAGE_PIN F29 [get_ports {inter_gpa_diff[143]}]
set_property PACKAGE_PIN F28 [get_ports {inter_gpa_diff[142]}]
set_property PACKAGE_PIN G29 [get_ports {inter_gpa_diff[141]}]
set_property PACKAGE_PIN H29 [get_ports {inter_gpa_diff[140]}]
set_property PACKAGE_PIN K27 [get_ports {inter_gpa_diff[139]}]
set_property PACKAGE_PIN K26 [get_ports {inter_gpa_diff[138]}]
set_property PACKAGE_PIN L27 [get_ports {inter_gpa_diff[137]}]
set_property PACKAGE_PIN M27 [get_ports {inter_gpa_diff[136]}]
set_property PACKAGE_PIN K28 [get_ports {inter_gpa_diff[135]}]
set_property PACKAGE_PIN L28 [get_ports {inter_gpa_diff[134]}]
set_property PACKAGE_PIN L29 [get_ports {inter_gpa_diff[133]}]
set_property PACKAGE_PIN M29 [get_ports {inter_gpa_diff[132]}]
set_property PACKAGE_PIN N26 [get_ports {inter_gpa_diff[131]}]
set_property PACKAGE_PIN P26 [get_ports {inter_gpa_diff[130]}]
set_property PACKAGE_PIN N28 [get_ports {inter_gpa_diff[129]}]
set_property PACKAGE_PIN P28 [get_ports {inter_gpa_diff[128]}]
set_property PACKAGE_PIN N29 [get_ports {inter_gpa_diff[127]}]
set_property PACKAGE_PIN P29 [get_ports {inter_gpa_diff[126]}]
set_property PACKAGE_PIN R26 [get_ports {inter_gpa_diff[125]}]
set_property PACKAGE_PIN T26 [get_ports {inter_gpa_diff[124]}]
set_property PACKAGE_PIN R27 [get_ports {inter_gpa_diff[123]}]
set_property PACKAGE_PIN T27 [get_ports {inter_gpa_diff[122]}]
set_property PACKAGE_PIN R28 [get_ports {inter_gpa_diff[121]}]
set_property PACKAGE_PIN T28 [get_ports {inter_gpa_diff[120]}]
set_property PACKAGE_PIN C31 [get_ports {inter_gpa_diff[119]}]
set_property PACKAGE_PIN D31 [get_ports {inter_gpa_diff[118]}]
set_property PACKAGE_PIN B32 [get_ports {inter_gpa_diff[117]}]
set_property PACKAGE_PIN C32 [get_ports {inter_gpa_diff[116]}]
set_property PACKAGE_PIN A33 [get_ports {inter_gpa_diff[115]}]
set_property PACKAGE_PIN A32 [get_ports {inter_gpa_diff[114]}]
set_property PACKAGE_PIN C33 [get_ports {inter_gpa_diff[113]}]
set_property PACKAGE_PIN D33 [get_ports {inter_gpa_diff[112]}]
set_property PACKAGE_PIN C34 [get_ports {inter_gpa_diff[111]}]
set_property PACKAGE_PIN D34 [get_ports {inter_gpa_diff[110]}]
set_property PACKAGE_PIN A34 [get_ports {inter_gpa_diff[109]}]
set_property PACKAGE_PIN B34 [get_ports {inter_gpa_diff[108]}]
set_property PACKAGE_PIN D35 [get_ports {inter_gpa_diff[107]}]
set_property PACKAGE_PIN E35 [get_ports {inter_gpa_diff[106]}]
set_property PACKAGE_PIN A35 [get_ports {inter_gpa_diff[105]}]
set_property PACKAGE_PIN B35 [get_ports {inter_gpa_diff[104]}]
set_property PACKAGE_PIN B37 [get_ports {inter_gpa_diff[103]}]
set_property PACKAGE_PIN B36 [get_ports {inter_gpa_diff[102]}]
set_property PACKAGE_PIN A38 [get_ports {inter_gpa_diff[101]}]
set_property PACKAGE_PIN A37 [get_ports {inter_gpa_diff[100]}]
set_property PACKAGE_PIN A39 [get_ports {inter_gpa_diff[99]}]
set_property PACKAGE_PIN B39 [get_ports {inter_gpa_diff[98]}]
set_property PACKAGE_PIN A40 [get_ports {inter_gpa_diff[97]}]
set_property PACKAGE_PIN B40 [get_ports {inter_gpa_diff[96]}]
set_property PACKAGE_PIN D39 [get_ports {inter_gpa_diff[95]}]
set_property PACKAGE_PIN E39 [get_ports {inter_gpa_diff[94]}]
set_property PACKAGE_PIN D40 [get_ports {inter_gpa_diff[93]}]
set_property PACKAGE_PIN E40 [get_ports {inter_gpa_diff[92]}]
set_property PACKAGE_PIN F35 [get_ports {inter_gpa_diff[91]}]
set_property PACKAGE_PIN F34 [get_ports {inter_gpa_diff[90]}]
set_property PACKAGE_PIN G34 [get_ports {inter_gpa_diff[89]}]
set_property PACKAGE_PIN H34 [get_ports {inter_gpa_diff[88]}]
set_property PACKAGE_PIN G36 [get_ports {inter_gpa_diff[87]}]
set_property PACKAGE_PIN H36 [get_ports {inter_gpa_diff[86]}]
set_property PACKAGE_PIN J36 [get_ports {inter_gpa_diff[85]}]
set_property PACKAGE_PIN J35 [get_ports {inter_gpa_diff[84]}]
set_property PACKAGE_PIN F37 [get_ports {inter_gpa_diff[83]}]
set_property PACKAGE_PIN G37 [get_ports {inter_gpa_diff[82]}]
set_property PACKAGE_PIN H38 [get_ports {inter_gpa_diff[81]}]
set_property PACKAGE_PIN H37 [get_ports {inter_gpa_diff[80]}]

set_property PACKAGE_PIN C28 [get_ports {inter_gpa_gpio[11]}]
set_property PACKAGE_PIN E26 [get_ports {inter_gpa_gpio[10]}]
set_property PACKAGE_PIN M26 [get_ports {inter_gpa_gpio[9]}]
set_property PACKAGE_PIN B31 [get_ports {inter_gpa_gpio[8]}]
set_property PACKAGE_PIN E37 [get_ports {inter_gpa_gpio[7]}]
set_property PACKAGE_PIN F38 [get_ports {inter_gpa_gpio[6]}]

set_property IOSTANDARD DIFF_HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[23]}]
set_property IOSTANDARD DIFF_HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[22]}]
set_property OUTPUT_IMPEDANCE RDRV_48_48 [get_ports {inter_gpa_diff_gc[23]}]
set_property OUTPUT_IMPEDANCE RDRV_48_48 [get_ports {inter_gpa_diff_gc[22]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[21]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[20]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[19]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[18]}]
set_property IOSTANDARD DIFF_HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[17]}]
set_property IOSTANDARD DIFF_HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[16]}]
set_property OUTPUT_IMPEDANCE RDRV_48_48 [get_ports {inter_gpa_diff_gc[17]}]
set_property OUTPUT_IMPEDANCE RDRV_48_48 [get_ports {inter_gpa_diff_gc[16]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[15]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[14]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[13]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[12]}]
set_property IOSTANDARD DIFF_HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[11]}]
set_property IOSTANDARD DIFF_HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[10]}]
set_property OUTPUT_IMPEDANCE RDRV_48_48 [get_ports {inter_gpa_diff_gc[11]}]
set_property OUTPUT_IMPEDANCE RDRV_48_48 [get_ports {inter_gpa_diff_gc[10]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[9]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[8]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[7]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[6]}]
set_property IOSTANDARD DIFF_HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[5]}]
set_property IOSTANDARD DIFF_HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[4]}]
set_property OUTPUT_IMPEDANCE RDRV_48_48 [get_ports {inter_gpa_diff_gc[5]}]
set_property OUTPUT_IMPEDANCE RDRV_48_48 [get_ports {inter_gpa_diff_gc[4]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[3]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[2]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[1]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff_gc[0]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpa_diff[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {inter_gpa_gpio[*]}]
set_property PULLUP true [get_ports {inter_gpa_gpio[9]}]
set_property PULLUP true [get_ports {inter_gpa_gpio[6]}]
set_property PULLUP true [get_ports {inter_gpa_gpio[3]}]
set_property PULLUP true [get_ports {inter_gpa_gpio[0]}]
# Onboard pulldown for inter_gpa_gpio[2,5,8,11]...

# set_property PACKAGE_PIN M15 [get_ports {inter_gpa_dci group 0}] ...... Connected to external precision 240ohm->ground...
set_property DCI_CASCADE {70} [get_iobanks 69]
set_property INTERNAL_VREF 0.90 [get_iobanks 69]
set_property INTERNAL_VREF 0.90 [get_iobanks 70]

# set_property PACKAGE_PIN V34 [get_ports {inter_gpa_dci group 1}] ...... Connected to external precision 240ohm->ground...
set_property DCI_CASCADE {50 51} [get_iobanks 49]
set_property INTERNAL_VREF 0.90 [get_iobanks 50]
set_property INTERNAL_VREF 0.90 [get_iobanks 51]

# Inter-FPGA General Purpose DCI Group
set_property PACKAGE_PIN AY36 [get_ports {inter_gpb_diff_gc[11]}]
set_property PACKAGE_PIN AY35 [get_ports {inter_gpb_diff_gc[10]}]
set_property PACKAGE_PIN BB34 [get_ports {inter_gpb_diff_gc[9]}]
set_property PACKAGE_PIN BA34 [get_ports {inter_gpb_diff_gc[8]}]
set_property PACKAGE_PIN BC36 [get_ports {inter_gpb_diff_gc[7]}]
set_property PACKAGE_PIN BB36 [get_ports {inter_gpb_diff_gc[6]}]
set_property PACKAGE_PIN AW31 [get_ports {inter_gpb_diff_gc[5]}]
set_property PACKAGE_PIN AV31 [get_ports {inter_gpb_diff_gc[4]}]
set_property PACKAGE_PIN AW30 [get_ports {inter_gpb_diff_gc[3]}]
set_property PACKAGE_PIN AW29 [get_ports {inter_gpb_diff_gc[2]}]
set_property PACKAGE_PIN BA30 [get_ports {inter_gpb_diff_gc[1]}]
set_property PACKAGE_PIN AY30 [get_ports {inter_gpb_diff_gc[0]}]

set_property PACKAGE_PIN AM34 [get_ports {inter_gpb_diff[79]}]
set_property PACKAGE_PIN AL34 [get_ports {inter_gpb_diff[78]}]
set_property PACKAGE_PIN AM32 [get_ports {inter_gpb_diff[77]}]
set_property PACKAGE_PIN AL32 [get_ports {inter_gpb_diff[76]}]
set_property PACKAGE_PIN AN33 [get_ports {inter_gpb_diff[75]}]
set_property PACKAGE_PIN AN32 [get_ports {inter_gpb_diff[74]}]
set_property PACKAGE_PIN AP34 [get_ports {inter_gpb_diff[73]}]
set_property PACKAGE_PIN AN34 [get_ports {inter_gpb_diff[72]}]
set_property PACKAGE_PIN AR33 [get_ports {inter_gpb_diff[71]}]
set_property PACKAGE_PIN AP33 [get_ports {inter_gpb_diff[70]}]
set_property PACKAGE_PIN AT34 [get_ports {inter_gpb_diff[69]}]
set_property PACKAGE_PIN AT33 [get_ports {inter_gpb_diff[68]}]
set_property PACKAGE_PIN AW33 [get_ports {inter_gpb_diff[67]}]
set_property PACKAGE_PIN AV33 [get_ports {inter_gpb_diff[66]}]
set_property PACKAGE_PIN AW34 [get_ports {inter_gpb_diff[65]}]
set_property PACKAGE_PIN AV34 [get_ports {inter_gpb_diff[64]}]
set_property PACKAGE_PIN AW36 [get_ports {inter_gpb_diff[63]}]
set_property PACKAGE_PIN AW35 [get_ports {inter_gpb_diff[62]}]
set_property PACKAGE_PIN BA33 [get_ports {inter_gpb_diff[61]}]
set_property PACKAGE_PIN AY33 [get_ports {inter_gpb_diff[60]}]
set_property PACKAGE_PIN BC37 [get_ports {inter_gpb_diff[59]}]
set_property PACKAGE_PIN BB37 [get_ports {inter_gpb_diff[58]}]
set_property PACKAGE_PIN BE36 [get_ports {inter_gpb_diff[57]}]
set_property PACKAGE_PIN BD36 [get_ports {inter_gpb_diff[56]}]
set_property PACKAGE_PIN BE35 [get_ports {inter_gpb_diff[55]}]
set_property PACKAGE_PIN BD35 [get_ports {inter_gpb_diff[54]}]
set_property PACKAGE_PIN BD34 [get_ports {inter_gpb_diff[53]}]
set_property PACKAGE_PIN BC34 [get_ports {inter_gpb_diff[52]}]
set_property PACKAGE_PIN BC38 [get_ports {inter_gpb_diff[51]}]
set_property PACKAGE_PIN BB38 [get_ports {inter_gpb_diff[50]}]
set_property PACKAGE_PIN BD39 [get_ports {inter_gpb_diff[49]}]
set_property PACKAGE_PIN BC39 [get_ports {inter_gpb_diff[48]}]
set_property PACKAGE_PIN BE40 [get_ports {inter_gpb_diff[47]}]
set_property PACKAGE_PIN BD40 [get_ports {inter_gpb_diff[46]}]
set_property PACKAGE_PIN BF37 [get_ports {inter_gpb_diff[45]}]
set_property PACKAGE_PIN BE37 [get_ports {inter_gpb_diff[44]}]
set_property PACKAGE_PIN BF38 [get_ports {inter_gpb_diff[43]}]
set_property PACKAGE_PIN BE38 [get_ports {inter_gpb_diff[42]}]
set_property PACKAGE_PIN BF40 [get_ports {inter_gpb_diff[41]}]
set_property PACKAGE_PIN BF39 [get_ports {inter_gpb_diff[40]}]
set_property PACKAGE_PIN AL30 [get_ports {inter_gpb_diff[39]}]
set_property PACKAGE_PIN AL29 [get_ports {inter_gpb_diff[38]}]
set_property PACKAGE_PIN AN31 [get_ports {inter_gpb_diff[37]}]
set_property PACKAGE_PIN AM31 [get_ports {inter_gpb_diff[36]}]
set_property PACKAGE_PIN AM30 [get_ports {inter_gpb_diff[35]}]
set_property PACKAGE_PIN AM29 [get_ports {inter_gpb_diff[34]}]
set_property PACKAGE_PIN AP29 [get_ports {inter_gpb_diff[33]}]
set_property PACKAGE_PIN AN29 [get_ports {inter_gpb_diff[32]}]
set_property PACKAGE_PIN AR30 [get_ports {inter_gpb_diff[31]}]
set_property PACKAGE_PIN AP30 [get_ports {inter_gpb_diff[30]}]
set_property PACKAGE_PIN AR31 [get_ports {inter_gpb_diff[29]}]
set_property PACKAGE_PIN AP31 [get_ports {inter_gpb_diff[28]}]
set_property PACKAGE_PIN AT30 [get_ports {inter_gpb_diff[27]}]
set_property PACKAGE_PIN AT29 [get_ports {inter_gpb_diff[26]}]
set_property PACKAGE_PIN AU31 [get_ports {inter_gpb_diff[25]}]
set_property PACKAGE_PIN AU30 [get_ports {inter_gpb_diff[24]}]
set_property PACKAGE_PIN AV29 [get_ports {inter_gpb_diff[23]}]
set_property PACKAGE_PIN AU29 [get_ports {inter_gpb_diff[22]}]
set_property PACKAGE_PIN AV32 [get_ports {inter_gpb_diff[21]}]
set_property PACKAGE_PIN AU32 [get_ports {inter_gpb_diff[20]}]
set_property PACKAGE_PIN BB32 [get_ports {inter_gpb_diff[19]}]
set_property PACKAGE_PIN BA32 [get_ports {inter_gpb_diff[18]}]
set_property PACKAGE_PIN BB29 [get_ports {inter_gpb_diff[17]}]
set_property PACKAGE_PIN BA29 [get_ports {inter_gpb_diff[16]}]
set_property PACKAGE_PIN BB31 [get_ports {inter_gpb_diff[15]}]
set_property PACKAGE_PIN BB30 [get_ports {inter_gpb_diff[14]}]
set_property PACKAGE_PIN BC32 [get_ports {inter_gpb_diff[13]}]
set_property PACKAGE_PIN BC31 [get_ports {inter_gpb_diff[12]}]
set_property PACKAGE_PIN BD29 [get_ports {inter_gpb_diff[11]}]
set_property PACKAGE_PIN BC29 [get_ports {inter_gpb_diff[10]}]
set_property PACKAGE_PIN BE33 [get_ports {inter_gpb_diff[9]}]
set_property PACKAGE_PIN BD33 [get_ports {inter_gpb_diff[8]}]
set_property PACKAGE_PIN BD31 [get_ports {inter_gpb_diff[7]}]
set_property PACKAGE_PIN BD30 [get_ports {inter_gpb_diff[6]}]
set_property PACKAGE_PIN BF30 [get_ports {inter_gpb_diff[5]}]
set_property PACKAGE_PIN BE30 [get_ports {inter_gpb_diff[4]}]
set_property PACKAGE_PIN BE32 [get_ports {inter_gpb_diff[3]}]
set_property PACKAGE_PIN BE31 [get_ports {inter_gpb_diff[2]}]
set_property PACKAGE_PIN BF33 [get_ports {inter_gpb_diff[1]}]
set_property PACKAGE_PIN BF32 [get_ports {inter_gpb_diff[0]}]

set_property PACKAGE_PIN AL33 [get_ports {inter_gpb_gpio[5]}]
set_property PACKAGE_PIN AU34 [get_ports {inter_gpb_gpio[4]}]
set_property PACKAGE_PIN BF35 [get_ports {inter_gpb_gpio[3]}]
set_property PACKAGE_PIN AR32 [get_ports {inter_gpb_gpio[2]}]
set_property PACKAGE_PIN AT32 [get_ports {inter_gpb_gpio[1]}]
set_property PACKAGE_PIN BC33 [get_ports {inter_gpb_gpio[0]}]

set_property IOSTANDARD DIFF_HSTL_I_DCI_18 [get_ports {inter_gpb_diff_gc[11]}]
set_property IOSTANDARD DIFF_HSTL_I_DCI_18 [get_ports {inter_gpb_diff_gc[10]}]
set_property OUTPUT_IMPEDANCE RDRV_48_48 [get_ports {inter_gpb_diff_gc[11]}]
set_property OUTPUT_IMPEDANCE RDRV_48_48 [get_ports {inter_gpb_diff_gc[10]}]
set_property IOSTANDARD LVCMOS18 [get_ports {inter_gpb_diff_gc[9]}]
set_property IOSTANDARD LVCMOS18 [get_ports {inter_gpb_diff_gc[8]}]
set_property IOSTANDARD LVCMOS18 [get_ports {inter_gpb_diff_gc[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {inter_gpb_diff_gc[6]}]
set_property IOSTANDARD DIFF_HSTL_I_DCI_18 [get_ports {inter_gpb_diff_gc[5]}]
set_property IOSTANDARD DIFF_HSTL_I_DCI_18 [get_ports {inter_gpb_diff_gc[4]}]
set_property OUTPUT_IMPEDANCE RDRV_48_48 [get_ports {inter_gpb_diff_gc[5]}]
set_property OUTPUT_IMPEDANCE RDRV_48_48 [get_ports {inter_gpb_diff_gc[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {inter_gpb_diff_gc[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {inter_gpb_diff_gc[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {inter_gpb_diff_gc[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {inter_gpb_diff_gc[0]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {inter_gpb_diff[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {inter_gpb_gpio[*]}]
set_property PULLUP true [get_ports {inter_gpb_gpio[3]}]
set_property PULLUP true [get_ports {inter_gpb_gpio[0]}]
# Onboard pulldown for inter_gpb_gpio[2,5]...

# set_property PACKAGE_PIN BF34 [get_ports {inter_gpb_dci group 0}] ...... Connected to external precision 240ohm->ground...
set_property DCI_CASCADE {45} [get_iobanks 44]
set_property INTERNAL_VREF 0.90 [get_iobanks 44]
set_property INTERNAL_VREF 0.90 [get_iobanks 45]

set_property PACKAGE_PIN AM27 [get_ports {i2c_scl[0]}]
set_property PACKAGE_PIN AN27 [get_ports {i2c_sda[0]}]
set_property PACKAGE_PIN BF12 [get_ports {i2c_scl[1]}]
set_property PACKAGE_PIN BE12 [get_ports {i2c_sda[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {i2c_scl[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {i2c_sda[*]}]
set_property DRIVE 4 [get_ports {i2c_scl[*]}]
set_property DRIVE 8 [get_ports {i2c_sda[0]}]
set_property DRIVE 4 [get_ports {i2c_sda[1]}]
set_property SLEW SLOW [get_ports {i2c_scl[*]}]
set_property SLEW SLOW [get_ports {i2c_sda[*]}]
# Onboard Pullups for the I2C Interfaces...

set_property PACKAGE_PIN AH18 [get_ports vn]
set_property PACKAGE_PIN AG19 [get_ports vp]
set_property IOSTANDARD ANALOG [get_ports vp]
set_property IOSTANDARD ANALOG [get_ports vn]

set_property PACKAGE_PIN BF9  [get_ports {gpio[0]}]
set_property PACKAGE_PIN BF10 [get_ports {gpio[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {gpio[*]}]
set_property DRIVE 4 [get_ports  {gpio[*]}]
set_property SLEW SLOW [get_ports  {gpio[*]}]



# set_property PACKAGE_PIN AG13 [get_ports flash_clk]
# set_property PACKAGE_PIN AG12 [get_ports {flash_cs_n[0]}]
# set_property PACKAGE_PIN AK12 [get_ports {flash_dq[0]}]
# set_property PACKAGE_PIN AJ12 [get_ports {flash_dq[1]}]
# set_property PACKAGE_PIN AL12 [get_ports {flash_dq[2]}]
# set_property PACKAGE_PIN AH12 [get_ports {flash_dq[3]}]
# set_property IOSTANDARD LVCMOS18 [get_ports {flash_*}]
# set_property DRIVE 4 [get_ports {flash_*}]
# set_property SLEW SLOW [get_ports {flash_*}]


