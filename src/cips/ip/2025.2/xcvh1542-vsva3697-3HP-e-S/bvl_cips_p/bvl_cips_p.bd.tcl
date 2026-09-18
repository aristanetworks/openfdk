#-------------------------------------------------------------------------------
#- Arista Networks, Inc. Confidential and Proprietary.
#- Copyright (c) 2026 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Maintainers:
#-   fdk-support@arista.com
#-
#- Description:
#-
#- Tags:
#-
#-------------------------------------------------------------------------------
#Tags
#license-bsd-3-clause

################################################################
# This is a generated script based on design: bvl_cips_p
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2025.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source bvl_cips_p_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvh1542-vsva3697-3HP-e-S
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name bvl_cips_p

# This script was generated for a remote BD. To create a non-remote design,
# change the variable <run_remote_bd_flow> to <0>.

set run_remote_bd_flow 1
if { $run_remote_bd_flow == 1 } {
  # Set the reference directory for source file relative paths (by default 
  # the value is script directory path)
  set origin_dir ./bvl_cips_p

  # Use origin directory path location variable, if specified in the tcl shell
  if { [info exists ::origin_dir_loc] } {
     set origin_dir $::origin_dir_loc
  }

  set str_bd_folder [file normalize ${origin_dir}]
  set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

  # Check if remote design exists on disk
  if { [file exists $str_bd_filepath ] == 1 } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2030 -severity "ERROR" "The remote BD file path <$str_bd_filepath> already exists!"}
     common::send_gid_msg -ssname BD::TCL -id 2031 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0>."
     common::send_gid_msg -ssname BD::TCL -id 2032 -severity "INFO" "Also make sure there is no design <$design_name> existing in your current project."

     return 1
  }

  # Check if design exists in memory
  set list_existing_designs [get_bd_designs -quiet $design_name]
  if { $list_existing_designs ne "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2033 -severity "ERROR" "The design <$design_name> already exists in this project! Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_gid_msg -ssname BD::TCL -id 2034 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Check if design exists on disk within project
  set list_existing_designs [get_files -quiet */${design_name}.bd]
  if { $list_existing_designs ne "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2035 -severity "ERROR" "The design <$design_name> already exists in this project at location:
    $list_existing_designs"}
     catch {common::send_gid_msg -ssname BD::TCL -id 2036 -severity "ERROR" "Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_gid_msg -ssname BD::TCL -id 2037 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Now can create the remote BD
  # NOTE - usage of <-dir> will create <$str_bd_folder/$design_name/$design_name.bd>
  create_bd_design -dir $str_bd_folder $design_name
} else {

  # Create regular design
  if { [catch {create_bd_design $design_name} errmsg] } {
     common::send_gid_msg -ssname BD::TCL -id 2038 -severity "INFO" "Please set a different value to variable <design_name>."

     return 1
  }
}

current_bd_design $design_name

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:versal_cips:3.4\
xilinx.com:ip:axi_noc:1.1\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk ]

  set pcie_s_axis_cc [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 pcie_s_axis_cc ]
  set_property -dict [ list \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {32} \
   ] $pcie_s_axis_cc

  set pcie_s_axis_rq [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 pcie_s_axis_rq ]
  set_property -dict [ list \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {108} \
   ] $pcie_s_axis_rq

  set pcie_cfg_interrupt [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:pcie3_cfg_interrupt_rtl:1.0 pcie_cfg_interrupt ]

  set pcie_cfg_control [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:pcie5_cfg_control_rtl:1.0 pcie_cfg_control ]

  set s_axi_pmc0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_pmc0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {49} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {200000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {2} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $s_axi_pmc0

  set pcie_gt [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 pcie_gt ]

  set pcie_cfg_status [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie5_cfg_status_rtl:1.0 pcie_cfg_status ]

  set pcie_m_axis_cq [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 pcie_m_axis_cq ]

  set pcie_m_axis_rc [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 pcie_m_axis_rc ]

  set s_axi_pmc1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_pmc1 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {49} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {200000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {2} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $s_axi_pmc1

  set s_axi_pmc2 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_pmc2 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {49} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {200000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {2} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $s_axi_pmc2

  set s_axi_pmc3 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_pmc3 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {49} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {200000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {2} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $s_axi_pmc3

  set m_axi_lpd [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_lpd ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {44} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {200000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_WSTRB {0} \
   CONFIG.NUM_READ_OUTSTANDING {32} \
   CONFIG.NUM_WRITE_OUTSTANDING {32} \
   CONFIG.PROTOCOL {AXI4} \
   ] $m_axi_lpd


  # Create ports
  set pl0_refclk [ create_bd_port -dir O -type clk pl0_refclk ]
  set cpm_irq0 [ create_bd_port -dir I -type intr cpm_irq0 ]
  set cpm_irq1 [ create_bd_port -dir I -type intr cpm_irq1 ]
  set s_axi_pmc0_clk [ create_bd_port -dir I -type clk -freq_hz 200000000 s_axi_pmc0_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {s_axi_pmc0} \
 ] $s_axi_pmc0_clk
  set pcie_user_lnk_up [ create_bd_port -dir O pcie_user_lnk_up ]
  set pcie_user_reset [ create_bd_port -dir O -type rst pcie_user_reset ]
  set cpm_uncor_irq [ create_bd_port -dir O -type intr cpm_uncor_irq ]
  set cpm_cor_irq [ create_bd_port -dir O -type intr cpm_cor_irq ]
  set cpm_misc_irq [ create_bd_port -dir O -type intr cpm_misc_irq ]
  set pcie_user_clk [ create_bd_port -dir O -type clk pcie_user_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {pcie_s_axis_rq:pcie_s_axis_cc:pcie_m_axis_cq:pcie_m_axis_rc} \
   CONFIG.ASSOCIATED_RESET {pcie_user_reset} \
 ] $pcie_user_clk
  set s_axi_pmc1_clk [ create_bd_port -dir I -type clk -freq_hz 200000000 s_axi_pmc1_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {s_axi_pmc1} \
 ] $s_axi_pmc1_clk
  set s_axi_pmc2_clk [ create_bd_port -dir I -type clk -freq_hz 200000000 s_axi_pmc2_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {s_axi_pmc2} \
 ] $s_axi_pmc2_clk
  set s_axi_pmc3_clk [ create_bd_port -dir I -type clk -freq_hz 200000000 s_axi_pmc3_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {s_axi_pmc3} \
 ] $s_axi_pmc3_clk
  set ps_lpd_gpo [ create_bd_port -dir O -from 31 -to 0 ps_lpd_gpo ]
  set ps_lpd_gpi [ create_bd_port -dir I -from 31 -to 0 ps_lpd_gpi ]
  set m_axi_lpd_clk [ create_bd_port -dir I -type clk -freq_hz 200000000 m_axi_lpd_clk ]
  set pl1_refclk [ create_bd_port -dir O -type clk pl1_refclk ]

  # Create instance: versal_cips_0, and set properties
  set versal_cips_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips:3.4 versal_cips_0 ]
  set_property -dict [list \
    CONFIG.BOOT_MODE {Custom} \
    CONFIG.CLOCK_MODE {Custom} \
    CONFIG.CPM_CONFIG { \
      CPM_PCIE0_AXISTEN_IF_WIDTH {256} \
      CPM_PCIE0_CFG_CTL_IF {1} \
      CPM_PCIE0_CFG_EXT_IF {0} \
      CPM_PCIE0_CFG_FC_IF {0} \
      CPM_PCIE0_CFG_MGMT_IF {0} \
      CPM_PCIE0_CFG_STS_IF {1} \
      CPM_PCIE0_MESG_RSVD_IF {0} \
      CPM_PCIE0_MESG_TRANSMIT_IF {0} \
      CPM_PCIE0_MODES {PCIE} \
      CPM_PCIE0_MODE_SELECTION {Advanced} \
      CPM_PCIE0_MSI_X_OPTIONS {None} \
      CPM_PCIE0_PASID_IF {0} \
      CPM_PCIE0_PF0_BAR0_64BIT {1} \
      CPM_PCIE0_PF0_BAR0_PREFETCHABLE {1} \
      CPM_PCIE0_PF0_BAR0_SCALE {Megabytes} \
      CPM_PCIE0_PF0_BAR0_SIZE {16} \
      CPM_PCIE0_PF0_MSI_ENABLED {0} \
      CPM_PCIE0_PL_LINK_CAP_MAX_LINK_WIDTH {X4} \
      CPM_PCIE0_TX_FC_IF {0} \
      PS_USE_NOC_PS_PCI_0 {1} \
      PS_USE_PS_NOC_PCI_0 {1} \
      PS_USE_PS_NOC_PCI_1 {1} \
    } \
    CONFIG.DDR_MEMORY_MODE {Custom} \
    CONFIG.DEVICE_INTEGRITY_MODE {Custom} \
    CONFIG.IO_CONFIG_MODE {Custom} \
    CONFIG.PS_PL_CONNECTIVITY_MODE {Custom} \
    CONFIG.PS_PMC_CONFIG { \
      AURORA_LINE_RATE_GPBS {12.5} \
      BOOT_MODE {Custom} \
      BOOT_SECONDARY_PCIE_ENABLE {0} \
      CLOCK_MODE {Custom} \
      COHERENCY_MODE {Custom} \
      CPM_PCIE0_MODES {None} \
      CPM_PCIE0_PL_LINK_CAP_MAX_LINK_WIDTH {X4} \
      CPM_PCIE0_TANDEM {None} \
      CPM_PCIE1_MODES {None} \
      CPM_PCIE1_PL_LINK_CAP_MAX_LINK_WIDTH {X4} \
      DDR_MEMORY_MODE {Custom} \
      DEBUG_MODE {Custom} \
      DESIGN_MODE {1} \
      DEVICE_INTEGRITY_MODE {Custom} \
      DIS_AUTO_POL_CHECK {0} \
      GT_REFCLK_MHZ {156.25} \
      INIT_CLK_MHZ {125} \
      INV_POLARITY {0} \
      IO_CONFIG_MODE {Custom} \
      JTAG_USERCODE {0x0} \
      OT_EAM_RESP {SRST} \
      PCIE_APERTURES_DUAL_ENABLE {0} \
      PCIE_APERTURES_SINGLE_ENABLE {0} \
      PERFORMANCE_MODE {Custom} \
      PL_SEM_GPIO_ENABLE {1} \
      PMC_ALT_REF_CLK_FREQMHZ {33.333} \
      PMC_BANK_0_IO_STANDARD {LVCMOS3.3} \
      PMC_BANK_1_IO_STANDARD {LVCMOS3.3} \
      PMC_CIPS_MODE {ADVANCE} \
      PMC_CLKMON0_CONFIG {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON0_CONFIG_1 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON0_CONFIG_2 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON0_CONFIG_3 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON1_CONFIG {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON1_CONFIG_1 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON1_CONFIG_2 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON1_CONFIG_3 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON2_CONFIG {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON2_CONFIG_1 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON2_CONFIG_2 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON2_CONFIG_3 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON3_CONFIG {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON3_CONFIG_1 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON3_CONFIG_2 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON3_CONFIG_3 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON4_CONFIG {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON4_CONFIG_1 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON4_CONFIG_2 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON4_CONFIG_3 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON5_CONFIG {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON5_CONFIG_1 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON5_CONFIG_2 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON5_CONFIG_3 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON6_CONFIG {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON6_CONFIG_1 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON6_CONFIG_2 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON6_CONFIG_3 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON7_CONFIG {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON7_CONFIG_1 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON7_CONFIG_2 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CLKMON7_CONFIG_3 {{BASE 10000} {BASE_CLK_SRC REF_CLK} {CLKA_FREQ 1000} {CLKA_SEL REF_CLK} {ENABLE 0} {INTR 0} {THRESHOLD_L 0} {THRESHOLD_U 0}} \
      PMC_CORE_SUBSYSTEM_LOAD {10} \
      PMC_CRP_CFU_REF_CTRL_ACT_FREQMHZ {400.000000} \
      PMC_CRP_CFU_REF_CTRL_DIVISOR0 {3} \
      PMC_CRP_CFU_REF_CTRL_FREQMHZ {400} \
      PMC_CRP_CFU_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_DFT_OSC_REF_CTRL_ACT_FREQMHZ {400} \
      PMC_CRP_DFT_OSC_REF_CTRL_DIVISOR0 {3} \
      PMC_CRP_DFT_OSC_REF_CTRL_FREQMHZ {400} \
      PMC_CRP_DFT_OSC_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_EFUSE_REF_CTRL_ACT_FREQMHZ {100.000000} \
      PMC_CRP_EFUSE_REF_CTRL_FREQMHZ {100.000000} \
      PMC_CRP_EFUSE_REF_CTRL_SRCSEL {IRO_CLK/4} \
      PMC_CRP_HSM0_REF_CTRL_ACT_FREQMHZ {200.000000} \
      PMC_CRP_HSM0_REF_CTRL_DIVISOR0 {6} \
      PMC_CRP_HSM0_REF_CTRL_FREQMHZ {200} \
      PMC_CRP_HSM0_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_HSM1_REF_CTRL_ACT_FREQMHZ {200.000000} \
      PMC_CRP_HSM1_REF_CTRL_DIVISOR0 {6} \
      PMC_CRP_HSM1_REF_CTRL_FREQMHZ {200} \
      PMC_CRP_HSM1_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_I2C_REF_CTRL_ACT_FREQMHZ {100} \
      PMC_CRP_I2C_REF_CTRL_DIVISOR0 {12} \
      PMC_CRP_I2C_REF_CTRL_FREQMHZ {100} \
      PMC_CRP_I2C_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_LSBUS_REF_CTRL_ACT_FREQMHZ {150.000000} \
      PMC_CRP_LSBUS_REF_CTRL_DIVISOR0 {8} \
      PMC_CRP_LSBUS_REF_CTRL_FREQMHZ {150} \
      PMC_CRP_LSBUS_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_NOC_REF_CTRL_ACT_FREQMHZ {1075.000000} \
      PMC_CRP_NOC_REF_CTRL_FREQMHZ {1080} \
      PMC_CRP_NOC_REF_CTRL_SRCSEL {NPLL} \
      PMC_CRP_NPI_REF_CTRL_ACT_FREQMHZ {300.000000} \
      PMC_CRP_NPI_REF_CTRL_DIVISOR0 {4} \
      PMC_CRP_NPI_REF_CTRL_FREQMHZ {300} \
      PMC_CRP_NPI_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_NPLL_CTRL_CLKOUTDIV {4} \
      PMC_CRP_NPLL_CTRL_FBDIV {86} \
      PMC_CRP_NPLL_CTRL_SRCSEL {REF_CLK} \
      PMC_CRP_NPLL_TO_XPD_CTRL_DIVISOR0 {4} \
      PMC_CRP_OSPI_REF_CTRL_ACT_FREQMHZ {200} \
      PMC_CRP_OSPI_REF_CTRL_DIVISOR0 {4} \
      PMC_CRP_OSPI_REF_CTRL_FREQMHZ {200} \
      PMC_CRP_OSPI_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_PL0_REF_CTRL_ACT_FREQMHZ {200.000000} \
      PMC_CRP_PL0_REF_CTRL_DIVISOR0 {6} \
      PMC_CRP_PL0_REF_CTRL_FREQMHZ {200} \
      PMC_CRP_PL0_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_PL1_REF_CTRL_ACT_FREQMHZ {400.000000} \
      PMC_CRP_PL1_REF_CTRL_DIVISOR0 {3} \
      PMC_CRP_PL1_REF_CTRL_FREQMHZ {400} \
      PMC_CRP_PL1_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_PL2_REF_CTRL_ACT_FREQMHZ {100} \
      PMC_CRP_PL2_REF_CTRL_DIVISOR0 {3} \
      PMC_CRP_PL2_REF_CTRL_FREQMHZ {400} \
      PMC_CRP_PL2_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_PL3_REF_CTRL_ACT_FREQMHZ {100} \
      PMC_CRP_PL3_REF_CTRL_DIVISOR0 {3} \
      PMC_CRP_PL3_REF_CTRL_FREQMHZ {400} \
      PMC_CRP_PL3_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_PL5_REF_CTRL_FREQMHZ {400} \
      PMC_CRP_PPLL_CTRL_CLKOUTDIV {2} \
      PMC_CRP_PPLL_CTRL_FBDIV {48} \
      PMC_CRP_PPLL_CTRL_SRCSEL {REF_CLK} \
      PMC_CRP_PPLL_TO_XPD_CTRL_DIVISOR0 {3} \
      PMC_CRP_QSPI_REF_CTRL_ACT_FREQMHZ {300.000000} \
      PMC_CRP_QSPI_REF_CTRL_DIVISOR0 {4} \
      PMC_CRP_QSPI_REF_CTRL_FREQMHZ {300} \
      PMC_CRP_QSPI_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_SDIO0_REF_CTRL_ACT_FREQMHZ {200} \
      PMC_CRP_SDIO0_REF_CTRL_DIVISOR0 {6} \
      PMC_CRP_SDIO0_REF_CTRL_FREQMHZ {200} \
      PMC_CRP_SDIO0_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_SDIO1_REF_CTRL_ACT_FREQMHZ {200} \
      PMC_CRP_SDIO1_REF_CTRL_DIVISOR0 {6} \
      PMC_CRP_SDIO1_REF_CTRL_FREQMHZ {200} \
      PMC_CRP_SDIO1_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_SD_DLL_REF_CTRL_ACT_FREQMHZ {1200} \
      PMC_CRP_SD_DLL_REF_CTRL_DIVISOR0 {1} \
      PMC_CRP_SD_DLL_REF_CTRL_FREQMHZ {1200} \
      PMC_CRP_SD_DLL_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_SWITCH_TIMEOUT_CTRL_ACT_FREQMHZ {1.000000} \
      PMC_CRP_SWITCH_TIMEOUT_CTRL_DIVISOR0 {100} \
      PMC_CRP_SWITCH_TIMEOUT_CTRL_FREQMHZ {1} \
      PMC_CRP_SWITCH_TIMEOUT_CTRL_SRCSEL {IRO_CLK/4} \
      PMC_CRP_SYSMON_REF_CTRL_ACT_FREQMHZ {300.000000} \
      PMC_CRP_SYSMON_REF_CTRL_FREQMHZ {300.000000} \
      PMC_CRP_SYSMON_REF_CTRL_SRCSEL {NPI_REF_CLK} \
      PMC_CRP_TEST_PATTERN_REF_CTRL_ACT_FREQMHZ {200} \
      PMC_CRP_TEST_PATTERN_REF_CTRL_DIVISOR0 {6} \
      PMC_CRP_TEST_PATTERN_REF_CTRL_FREQMHZ {200} \
      PMC_CRP_TEST_PATTERN_REF_CTRL_SRCSEL {PPLL} \
      PMC_CRP_USB_SUSPEND_CTRL_ACT_FREQMHZ {0.200000} \
      PMC_CRP_USB_SUSPEND_CTRL_DIVISOR0 {500} \
      PMC_CRP_USB_SUSPEND_CTRL_FREQMHZ {0.2} \
      PMC_CRP_USB_SUSPEND_CTRL_SRCSEL {IRO_CLK/4} \
      PMC_EXTERNAL_TAMPER {{ENABLE 0} {IO {PMC_MIO 12}}} \
      PMC_EXTERNAL_TAMPER_1 {{ENABLE 0} {IO None}} \
      PMC_EXTERNAL_TAMPER_2 {{ENABLE 0} {IO None}} \
      PMC_EXTERNAL_TAMPER_3 {{ENABLE 0} {IO None}} \
      PMC_GLITCH_CONFIG {{DEPTH_SENSITIVITY 1} {MIN_PULSE_WIDTH 0.5} {TYPE EFUSE} {VCC_PMC_VALUE 0.88}} \
      PMC_GLITCH_CONFIG_1 {{DEPTH_SENSITIVITY 1} {MIN_PULSE_WIDTH 0.5} {TYPE EFUSE} {VCC_PMC_VALUE 0.88}} \
      PMC_GLITCH_CONFIG_2 {{DEPTH_SENSITIVITY 1} {MIN_PULSE_WIDTH 0.5} {TYPE EFUSE} {VCC_PMC_VALUE 0.88}} \
      PMC_GLITCH_CONFIG_3 {{DEPTH_SENSITIVITY 1} {MIN_PULSE_WIDTH 0.5} {TYPE EFUSE} {VCC_PMC_VALUE 0.88}} \
      PMC_GPIO0_MIO_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 0 .. 25}}} \
      PMC_GPIO1_MIO_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 26 .. 51}}} \
      PMC_GPIO_EMIO_PERIPHERAL_ENABLE {0} \
      PMC_GPIO_EMIO_WIDTH {64} \
      PMC_GPIO_EMIO_WIDTH_HDL {64} \
      PMC_GPI_ENABLE {0} \
      PMC_GPI_WIDTH {32} \
      PMC_GPO_ENABLE {0} \
      PMC_GPO_WIDTH {32} \
      PMC_HSM0_CLK_ENABLE {1} \
      PMC_HSM0_CLK_OUT_ENABLE {0} \
      PMC_HSM1_CLK_ENABLE {1} \
      PMC_HSM1_CLK_OUT_ENABLE {0} \
      PMC_I2CPMC_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 2 .. 3}}} \
      PMC_MIO0 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 12mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO1 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 12mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO10 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 12mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO11 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 12mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO12 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 12mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO13 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO14 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO15 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO16 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO17 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO18 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO19 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO2 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 12mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO20 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pulldown} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO21 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO22 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO23 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO24 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO25 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO26 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO27 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO28 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO29 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO3 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 12mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO30 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO31 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO32 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO33 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO34 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO35 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO36 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO37 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO38 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO39 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO4 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 12mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO40 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO41 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO42 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO43 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO44 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO45 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO46 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO47 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO48 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO49 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO5 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 12mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO50 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO51 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PMC_MIO6 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 12mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO7 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 12mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO8 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 12mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO9 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 12mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO_EN_FOR_PL_PCIE {0} \
      PMC_MIO_TREE_PERIPHERALS {QSPI#QSPI#QSPI#QSPI#QSPI#QSPI#Loopback Clk#QSPI#QSPI#QSPI#QSPI#QSPI#QSPI##SMAP#SMAP#SMAP#SMAP#SMAP#SMAP#SMAP#SMAP#SMAP#SMAP#SMAP#SMAP#UART 0#UART 0###########################################PCIE#######}\
\
      PMC_MIO_TREE_SIGNALS {qspi0_clk#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]#qspi0_io[0]#qspi0_cs_b#qspi_lpbk#qspi1_cs_b#qspi1_io[0]#qspi1_io[1]#qspi1_io[2]#qspi1_io[3]#qspi1_clk##smap_io[0]#smap_io[1]#smap_io[2]#smap_io[3]#smap_clk#smap_cs_b#smap_rdwr_b#smap_busy#smap_io[4]#smap_io[5]#smap_io[6]#smap_io[7]#rxd#txd###########################################reset1_n#######}\
\
      PMC_NOC_PMC_ADDR_WIDTH {64} \
      PMC_NOC_PMC_DATA_WIDTH {128} \
      PMC_OSPI_COHERENCY {0} \
      PMC_OSPI_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 0 .. 11}} {MODE Single}} \
      PMC_OSPI_ROUTE_THROUGH_FPD {0} \
      PMC_OT_CHECK {{DELAY 0} {ENABLE 1}} \
      PMC_PL_ALT_REF_CLK_FREQMHZ {33.333} \
      PMC_PMC_NOC_ADDR_WIDTH {64} \
      PMC_PMC_NOC_DATA_WIDTH {128} \
      PMC_QSPI_BAUD_RATE_DIV {8} \
      PMC_QSPI_COHERENCY {0} \
      PMC_QSPI_FBCLK {{ENABLE 1} {IO {PMC_MIO 6}}} \
      PMC_QSPI_PERIPHERAL_DATA_MODE {x4} \
      PMC_QSPI_PERIPHERAL_ENABLE {1} \
      PMC_QSPI_PERIPHERAL_MODE {Dual Parallel} \
      PMC_QSPI_ROUTE_THROUGH_FPD {0} \
      PMC_RAM_CFU_REF_CTRL_CSCAN_ACT_FREQMHZ {400.000000} \
      PMC_RAM_CFU_REF_CTRL_CSCAN_DIVISOR0 {3} \
      PMC_RAM_CFU_REF_CTRL_CSCAN_FREQMHZ {400} \
      PMC_RAM_CFU_REF_CTRL_CSCAN_SRCSEL {PPLL} \
      PMC_REF_CLK_FREQMHZ {50} \
      PMC_SD0 {{CD_ENABLE 0} {CD_IO {PMC_MIO 24}} {POW_ENABLE 0} {POW_IO {PMC_MIO 17}} {RESET_ENABLE 0} {RESET_IO {PMC_MIO 17}} {WP_ENABLE 0} {WP_IO {PMC_MIO 25}}} \
      PMC_SD0_COHERENCY {0} \
      PMC_SD0_DATA_TRANSFER_MODE {4Bit} \
      PMC_SD0_PERIPHERAL {{CLK_100_SDR_OTAP_DLY 0x00} {CLK_200_SDR_OTAP_DLY 0x00} {CLK_50_DDR_ITAP_DLY 0x00} {CLK_50_DDR_OTAP_DLY 0x00} {CLK_50_SDR_ITAP_DLY 0x00} {CLK_50_SDR_OTAP_DLY 0x00} {ENABLE 0}\
{IO {PMC_MIO 13 .. 25}}} \
      PMC_SD0_ROUTE_THROUGH_FPD {0} \
      PMC_SD0_SLOT_TYPE {SD 2.0} \
      PMC_SD0_SPEED_MODE {default speed} \
      PMC_SD1 {{CD_ENABLE 0} {CD_IO {PMC_MIO 2}} {POW_ENABLE 0} {POW_IO {PMC_MIO 12}} {RESET_ENABLE 0} {RESET_IO {PMC_MIO 12}} {WP_ENABLE 0} {WP_IO {PMC_MIO 1}}} \
      PMC_SD1_COHERENCY {0} \
      PMC_SD1_DATA_TRANSFER_MODE {4Bit} \
      PMC_SD1_PERIPHERAL {{CLK_100_SDR_OTAP_DLY 0x00} {CLK_200_SDR_OTAP_DLY 0x00} {CLK_50_DDR_ITAP_DLY 0x00} {CLK_50_DDR_OTAP_DLY 0x00} {CLK_50_SDR_ITAP_DLY 0x00} {CLK_50_SDR_OTAP_DLY 0x00} {ENABLE 0}\
{IO {PMC_MIO 0 .. 11}}} \
      PMC_SD1_ROUTE_THROUGH_FPD {0} \
      PMC_SD1_SLOT_TYPE {SD 2.0} \
      PMC_SD1_SPEED_MODE {default speed} \
      PMC_SHOW_CCI_SMMU_SETTINGS {0} \
      PMC_SMAP_PERIPHERAL {{ENABLE 1} {IO {8 Bit}}} \
      PMC_TAMPER_EXTMIO_ENABLE {0} \
      PMC_TAMPER_EXTMIO_ERASE_BBRAM {0} \
      PMC_TAMPER_EXTMIO_RESPONSE {SYS INTERRUPT} \
      PMC_TAMPER_GLITCHDETECT_ENABLE {0} \
      PMC_TAMPER_GLITCHDETECT_ENABLE_1 {0} \
      PMC_TAMPER_GLITCHDETECT_ENABLE_2 {0} \
      PMC_TAMPER_GLITCHDETECT_ENABLE_3 {0} \
      PMC_TAMPER_GLITCHDETECT_ERASE_BBRAM {0} \
      PMC_TAMPER_GLITCHDETECT_ERASE_BBRAM_1 {0} \
      PMC_TAMPER_GLITCHDETECT_ERASE_BBRAM_2 {0} \
      PMC_TAMPER_GLITCHDETECT_ERASE_BBRAM_3 {0} \
      PMC_TAMPER_GLITCHDETECT_RESPONSE {SYS INTERRUPT} \
      PMC_TAMPER_GLITCHDETECT_RESPONSE_1 {SYS INTERRUPT} \
      PMC_TAMPER_GLITCHDETECT_RESPONSE_2 {SYS INTERRUPT} \
      PMC_TAMPER_GLITCHDETECT_RESPONSE_3 {SYS INTERRUPT} \
      PMC_TAMPER_JTAGDETECT_ENABLE {0} \
      PMC_TAMPER_JTAGDETECT_ENABLE_1 {0} \
      PMC_TAMPER_JTAGDETECT_ENABLE_2 {0} \
      PMC_TAMPER_JTAGDETECT_ENABLE_3 {0} \
      PMC_TAMPER_JTAGDETECT_ERASE_BBRAM {0} \
      PMC_TAMPER_JTAGDETECT_ERASE_BBRAM_1 {0} \
      PMC_TAMPER_JTAGDETECT_ERASE_BBRAM_2 {0} \
      PMC_TAMPER_JTAGDETECT_ERASE_BBRAM_3 {0} \
      PMC_TAMPER_JTAGDETECT_RESPONSE {SYS INTERRUPT} \
      PMC_TAMPER_JTAGDETECT_RESPONSE_1 {SYS INTERRUPT} \
      PMC_TAMPER_JTAGDETECT_RESPONSE_2 {SYS INTERRUPT} \
      PMC_TAMPER_JTAGDETECT_RESPONSE_3 {SYS INTERRUPT} \
      PMC_TAMPER_SUP0 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 0} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP0_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 0} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP0_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 0} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP0_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 0} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 1} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP10 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 10} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP10_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 10} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP10_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 10} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP10_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 10} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP11 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 11} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP11_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 11} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP11_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 11} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP11_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 11} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP12 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 12} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP12_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 12} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP12_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 12} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP12_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 12} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP13 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 13} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP13_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 13} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP13_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 13} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP13_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 13} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP14 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 14} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP14_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 14} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP14_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 14} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP14_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 14} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP15 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 15} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP15_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 15} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP15_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 15} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP15_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 15} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP16 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 16} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP16_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 16} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP16_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 16} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP16_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 16} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP17 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 17} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP17_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 17} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP17_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 17} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP17_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 17} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP18 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 18} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP18_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 18} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP18_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 18} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP18_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 18} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP19 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 19} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP19_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 19} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP19_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 19} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP19_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 19} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP1_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 1} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP1_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 1} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP1_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 1} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 2} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP20 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 20} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP20_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 20} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP20_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 20} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP20_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 20} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP21 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 21} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP21_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 21} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP21_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 21} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP21_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 21} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP22 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 22} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP22_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 22} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP22_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 22} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP22_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 22} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP23 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 23} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP23_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 23} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP23_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 23} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP23_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 23} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP24 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 24} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP24_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 24} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP24_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 24} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP24_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 24} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP25 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 25} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP25_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 25} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP25_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 25} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP25_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 25} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP26 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 26} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP26_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 26} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP26_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 26} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP26_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 26} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP27 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 27} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP27_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 27} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP27_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 27} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP27_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 27} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP28 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 28} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP28_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 28} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP28_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 28} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP28_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 28} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP29 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 29} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP29_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 29} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP29_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 29} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP29_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 29} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP2_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 2} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP2_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 2} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP2_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 2} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 3} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP30 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 30} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP30_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 30} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP30_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 30} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP30_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 30} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP31 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 31} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP31_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 31} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP31_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 31} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP31_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 31} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP3_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 3} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP3_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 3} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP3_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 3} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP4 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 4} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP4_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 4} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP4_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 4} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP4_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 4} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP5 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 5} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP5_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 5} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP5_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 5} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP5_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 5} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP6 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 6} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP6_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 6} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP6_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 6} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP6_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 6} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP7 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 7} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP7_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 7} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP7_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 7} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP7_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 7} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP8 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 8} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP8_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 8} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP8_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 8} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP8_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 8} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP9 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {IO_N none} {IO_P none} {SUPPLY_NUM 9} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP9_1 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 9} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP9_2 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 9} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP9_3 {{ADC_MODE none} {AVG_ENABLE 0} {ENABLE 0} {SUPPLY_NUM 9} {TH_HIGH 0} {TH_LOW 0} {TH_MAX 0} {TH_MIN 0} {VOLTAGE none}} \
      PMC_TAMPER_SUP_0_31_ENABLE {0} \
      PMC_TAMPER_SUP_0_31_ENABLE_1 {0} \
      PMC_TAMPER_SUP_0_31_ENABLE_2 {0} \
      PMC_TAMPER_SUP_0_31_ENABLE_3 {0} \
      PMC_TAMPER_SUP_0_31_ERASE_BBRAM {0} \
      PMC_TAMPER_SUP_0_31_ERASE_BBRAM_1 {0} \
      PMC_TAMPER_SUP_0_31_ERASE_BBRAM_2 {0} \
      PMC_TAMPER_SUP_0_31_ERASE_BBRAM_3 {0} \
      PMC_TAMPER_SUP_0_31_RESPONSE {SYS INTERRUPT} \
      PMC_TAMPER_SUP_0_31_RESPONSE_1 {SYS INTERRUPT} \
      PMC_TAMPER_SUP_0_31_RESPONSE_2 {SYS INTERRUPT} \
      PMC_TAMPER_SUP_0_31_RESPONSE_3 {SYS INTERRUPT} \
      PMC_TAMPER_TEMPERATURE_ENABLE {0} \
      PMC_TAMPER_TEMPERATURE_ENABLE_1 {0} \
      PMC_TAMPER_TEMPERATURE_ENABLE_2 {0} \
      PMC_TAMPER_TEMPERATURE_ENABLE_3 {0} \
      PMC_TAMPER_TEMPERATURE_ERASE_BBRAM {0} \
      PMC_TAMPER_TEMPERATURE_ERASE_BBRAM_1 {0} \
      PMC_TAMPER_TEMPERATURE_ERASE_BBRAM_2 {0} \
      PMC_TAMPER_TEMPERATURE_ERASE_BBRAM_3 {0} \
      PMC_TAMPER_TEMPERATURE_RESPONSE {SYS INTERRUPT} \
      PMC_TAMPER_TEMPERATURE_RESPONSE_1 {SYS INTERRUPT} \
      PMC_TAMPER_TEMPERATURE_RESPONSE_2 {SYS INTERRUPT} \
      PMC_TAMPER_TEMPERATURE_RESPONSE_3 {SYS INTERRUPT} \
      PMC_USE_CFU_SEU {0} \
      PMC_USE_NOC_PMC_AXI0 {1} \
      PMC_USE_NOC_PMC_AXI1 {1} \
      PMC_USE_NOC_PMC_AXI2 {0} \
      PMC_USE_NOC_PMC_AXI3 {0} \
      PMC_USE_PL_PMC_AUX_REF_CLK {0} \
      PMC_USE_PMC_NOC_AXI0 {0} \
      PMC_USE_PMC_NOC_AXI1 {0} \
      PMC_USE_PMC_NOC_AXI2 {0} \
      PMC_USE_PMC_NOC_AXI3 {0} \
      PMC_WDT_PERIOD {100} \
      PMC_WDT_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 0}}} \
      POWER_REPORTING_MODE {Custom} \
      PSPMC_MANUAL_CLK_ENABLE {0} \
      PS_A72_ACTIVE_BLOCKS {2} \
      PS_A72_LOAD {90} \
      PS_BANK_2_IO_STANDARD {LVCMOS3.3} \
      PS_BANK_3_IO_STANDARD {LVCMOS3.3} \
      PS_BOARD_INTERFACE {Custom} \
      PS_CAN0_CLK {{ENABLE 0} {IO {PMC_MIO 0}}} \
      PS_CAN0_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 8 .. 9}}} \
      PS_CAN1_CLK {{ENABLE 0} {IO {PMC_MIO 0}}} \
      PS_CAN1_PERIPHERAL {{ENABLE 0} {IO {PS_MIO 16 .. 17}}} \
      PS_CRF_ACPU_CTRL_ACT_FREQMHZ {1700.000000} \
      PS_CRF_ACPU_CTRL_DIVISOR0 {1} \
      PS_CRF_ACPU_CTRL_FREQMHZ {1700} \
      PS_CRF_ACPU_CTRL_SRCSEL {APLL} \
      PS_CRF_APLL_CTRL_CLKOUTDIV {2} \
      PS_CRF_APLL_CTRL_FBDIV {68} \
      PS_CRF_APLL_CTRL_SRCSEL {REF_CLK} \
      PS_CRF_APLL_TO_XPD_CTRL_DIVISOR0 {4} \
      PS_CRF_DBG_FPD_CTRL_ACT_FREQMHZ {400.000000} \
      PS_CRF_DBG_FPD_CTRL_DIVISOR0 {1} \
      PS_CRF_DBG_FPD_CTRL_FREQMHZ {400} \
      PS_CRF_DBG_FPD_CTRL_SRCSEL {PPLL} \
      PS_CRF_DBG_TRACE_CTRL_ACT_FREQMHZ {300} \
      PS_CRF_DBG_TRACE_CTRL_DIVISOR0 {3} \
      PS_CRF_DBG_TRACE_CTRL_FREQMHZ {300} \
      PS_CRF_DBG_TRACE_CTRL_SRCSEL {PPLL} \
      PS_CRF_FPD_LSBUS_CTRL_ACT_FREQMHZ {150.000000} \
      PS_CRF_FPD_LSBUS_CTRL_DIVISOR0 {5} \
      PS_CRF_FPD_LSBUS_CTRL_FREQMHZ {150} \
      PS_CRF_FPD_LSBUS_CTRL_SRCSEL {RPLL} \
      PS_CRF_FPD_TOP_SWITCH_CTRL_ACT_FREQMHZ {850.000000} \
      PS_CRF_FPD_TOP_SWITCH_CTRL_DIVISOR0 {2} \
      PS_CRF_FPD_TOP_SWITCH_CTRL_FREQMHZ {1000} \
      PS_CRF_FPD_TOP_SWITCH_CTRL_SRCSEL {APLL} \
      PS_CRL_CAN0_REF_CTRL_ACT_FREQMHZ {100} \
      PS_CRL_CAN0_REF_CTRL_DIVISOR0 {6} \
      PS_CRL_CAN0_REF_CTRL_FREQMHZ {160} \
      PS_CRL_CAN0_REF_CTRL_SRCSEL {NPLL} \
      PS_CRL_CAN1_REF_CTRL_ACT_FREQMHZ {100} \
      PS_CRL_CAN1_REF_CTRL_DIVISOR0 {6} \
      PS_CRL_CAN1_REF_CTRL_FREQMHZ {160} \
      PS_CRL_CAN1_REF_CTRL_SRCSEL {NPLL} \
      PS_CRL_CPM_TOPSW_REF_CTRL_ACT_FREQMHZ {750.000000} \
      PS_CRL_CPM_TOPSW_REF_CTRL_DIVISOR0 {1} \
      PS_CRL_CPM_TOPSW_REF_CTRL_FREQMHZ {750} \
      PS_CRL_CPM_TOPSW_REF_CTRL_SRCSEL {RPLL} \
      PS_CRL_CPU_R5_CTRL_ACT_FREQMHZ {750.000000} \
      PS_CRL_CPU_R5_CTRL_DIVISOR0 {1} \
      PS_CRL_CPU_R5_CTRL_FREQMHZ {800} \
      PS_CRL_CPU_R5_CTRL_SRCSEL {RPLL} \
      PS_CRL_DBG_LPD_CTRL_ACT_FREQMHZ {400.000000} \
      PS_CRL_DBG_LPD_CTRL_DIVISOR0 {1} \
      PS_CRL_DBG_LPD_CTRL_FREQMHZ {400} \
      PS_CRL_DBG_LPD_CTRL_SRCSEL {PPLL} \
      PS_CRL_DBG_TSTMP_CTRL_ACT_FREQMHZ {400.000000} \
      PS_CRL_DBG_TSTMP_CTRL_DIVISOR0 {1} \
      PS_CRL_DBG_TSTMP_CTRL_FREQMHZ {400} \
      PS_CRL_DBG_TSTMP_CTRL_SRCSEL {PPLL} \
      PS_CRL_GEM0_REF_CTRL_ACT_FREQMHZ {125} \
      PS_CRL_GEM0_REF_CTRL_DIVISOR0 {12} \
      PS_CRL_GEM0_REF_CTRL_FREQMHZ {125} \
      PS_CRL_GEM0_REF_CTRL_SRCSEL {RPLL} \
      PS_CRL_GEM1_REF_CTRL_ACT_FREQMHZ {125} \
      PS_CRL_GEM1_REF_CTRL_DIVISOR0 {12} \
      PS_CRL_GEM1_REF_CTRL_FREQMHZ {125} \
      PS_CRL_GEM1_REF_CTRL_SRCSEL {RPLL} \
      PS_CRL_GEM_TSU_REF_CTRL_ACT_FREQMHZ {250} \
      PS_CRL_GEM_TSU_REF_CTRL_DIVISOR0 {6} \
      PS_CRL_GEM_TSU_REF_CTRL_FREQMHZ {250} \
      PS_CRL_GEM_TSU_REF_CTRL_SRCSEL {RPLL} \
      PS_CRL_I2C0_REF_CTRL_ACT_FREQMHZ {100} \
      PS_CRL_I2C0_REF_CTRL_DIVISOR0 {12} \
      PS_CRL_I2C0_REF_CTRL_FREQMHZ {100} \
      PS_CRL_I2C0_REF_CTRL_SRCSEL {PPLL} \
      PS_CRL_I2C1_REF_CTRL_ACT_FREQMHZ {100} \
      PS_CRL_I2C1_REF_CTRL_DIVISOR0 {12} \
      PS_CRL_I2C1_REF_CTRL_FREQMHZ {100} \
      PS_CRL_I2C1_REF_CTRL_SRCSEL {PPLL} \
      PS_CRL_IOU_SWITCH_CTRL_ACT_FREQMHZ {250.000000} \
      PS_CRL_IOU_SWITCH_CTRL_DIVISOR0 {3} \
      PS_CRL_IOU_SWITCH_CTRL_FREQMHZ {250} \
      PS_CRL_IOU_SWITCH_CTRL_SRCSEL {RPLL} \
      PS_CRL_LPD_LSBUS_CTRL_ACT_FREQMHZ {150.000000} \
      PS_CRL_LPD_LSBUS_CTRL_DIVISOR0 {5} \
      PS_CRL_LPD_LSBUS_CTRL_FREQMHZ {150} \
      PS_CRL_LPD_LSBUS_CTRL_SRCSEL {RPLL} \
      PS_CRL_LPD_TOP_SWITCH_CTRL_ACT_FREQMHZ {750.000000} \
      PS_CRL_LPD_TOP_SWITCH_CTRL_DIVISOR0 {1} \
      PS_CRL_LPD_TOP_SWITCH_CTRL_FREQMHZ {750} \
      PS_CRL_LPD_TOP_SWITCH_CTRL_SRCSEL {RPLL} \
      PS_CRL_PSM_REF_CTRL_ACT_FREQMHZ {400.000000} \
      PS_CRL_PSM_REF_CTRL_DIVISOR0 {1} \
      PS_CRL_PSM_REF_CTRL_FREQMHZ {400} \
      PS_CRL_PSM_REF_CTRL_SRCSEL {PPLL} \
      PS_CRL_RPLL_CTRL_CLKOUTDIV {4} \
      PS_CRL_RPLL_CTRL_FBDIV {60} \
      PS_CRL_RPLL_CTRL_SRCSEL {REF_CLK} \
      PS_CRL_RPLL_TO_XPD_CTRL_DIVISOR0 {1} \
      PS_CRL_SPI0_REF_CTRL_ACT_FREQMHZ {200} \
      PS_CRL_SPI0_REF_CTRL_DIVISOR0 {6} \
      PS_CRL_SPI0_REF_CTRL_FREQMHZ {200} \
      PS_CRL_SPI0_REF_CTRL_SRCSEL {PPLL} \
      PS_CRL_SPI1_REF_CTRL_ACT_FREQMHZ {200} \
      PS_CRL_SPI1_REF_CTRL_DIVISOR0 {6} \
      PS_CRL_SPI1_REF_CTRL_FREQMHZ {200} \
      PS_CRL_SPI1_REF_CTRL_SRCSEL {PPLL} \
      PS_CRL_TIMESTAMP_REF_CTRL_ACT_FREQMHZ {100.000000} \
      PS_CRL_TIMESTAMP_REF_CTRL_DIVISOR0 {4} \
      PS_CRL_TIMESTAMP_REF_CTRL_FREQMHZ {100} \
      PS_CRL_TIMESTAMP_REF_CTRL_SRCSEL {PPLL} \
      PS_CRL_UART0_REF_CTRL_ACT_FREQMHZ {100.000000} \
      PS_CRL_UART0_REF_CTRL_DIVISOR0 {4} \
      PS_CRL_UART0_REF_CTRL_FREQMHZ {100} \
      PS_CRL_UART0_REF_CTRL_SRCSEL {PPLL} \
      PS_CRL_UART1_REF_CTRL_ACT_FREQMHZ {100} \
      PS_CRL_UART1_REF_CTRL_DIVISOR0 {12} \
      PS_CRL_UART1_REF_CTRL_FREQMHZ {100} \
      PS_CRL_UART1_REF_CTRL_SRCSEL {PPLL} \
      PS_CRL_USB0_BUS_REF_CTRL_ACT_FREQMHZ {20} \
      PS_CRL_USB0_BUS_REF_CTRL_DIVISOR0 {60} \
      PS_CRL_USB0_BUS_REF_CTRL_FREQMHZ {20} \
      PS_CRL_USB0_BUS_REF_CTRL_SRCSEL {PPLL} \
      PS_CRL_USB3_DUAL_REF_CTRL_ACT_FREQMHZ {20} \
      PS_CRL_USB3_DUAL_REF_CTRL_DIVISOR0 {60} \
      PS_CRL_USB3_DUAL_REF_CTRL_FREQMHZ {10} \
      PS_CRL_USB3_DUAL_REF_CTRL_SRCSEL {PPLL} \
      PS_DDRC_ENABLE {1} \
      PS_DDR_RAM_HIGHADDR_OFFSET {0x800000000} \
      PS_DDR_RAM_LOWADDR_OFFSET {0x80000000} \
      PS_ENET0_MDIO {{ENABLE 0} {IO {PMC_MIO 50 .. 51}}} \
      PS_ENET0_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 26 .. 37}}} \
      PS_ENET1_MDIO {{ENABLE 0} {IO {PMC_MIO 50 .. 51}}} \
      PS_ENET1_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 38 .. 49}}} \
      PS_EN_AXI_STATUS_PORTS {0} \
      PS_EN_PORTS_CONTROLLER_BASED {0} \
      PS_EXPAND_CORESIGHT {0} \
      PS_EXPAND_FPD_SLAVES {0} \
      PS_EXPAND_GIC {0} \
      PS_EXPAND_LPD_SLAVES {0} \
      PS_FPD_INTERCONNECT_LOAD {90} \
      PS_FTM_CTI_IN0 {0} \
      PS_FTM_CTI_IN1 {0} \
      PS_FTM_CTI_IN2 {0} \
      PS_FTM_CTI_IN3 {0} \
      PS_FTM_CTI_OUT0 {0} \
      PS_FTM_CTI_OUT1 {0} \
      PS_FTM_CTI_OUT2 {0} \
      PS_FTM_CTI_OUT3 {0} \
      PS_GEM0_COHERENCY {0} \
      PS_GEM0_ROUTE_THROUGH_FPD {0} \
      PS_GEM0_TSU_INC_CTRL {3} \
      PS_GEM1_COHERENCY {0} \
      PS_GEM1_ROUTE_THROUGH_FPD {0} \
      PS_GEM_TSU {{ENABLE 0} {IO {PS_MIO 24}}} \
      PS_GEM_TSU_CLK_PORT_PAIR {0} \
      PS_GEN_IPI0_ENABLE {1} \
      PS_GEN_IPI0_MASTER {R5_0} \
      PS_GEN_IPI1_ENABLE {1} \
      PS_GEN_IPI1_MASTER {R5_1} \
      PS_GEN_IPI2_ENABLE {1} \
      PS_GEN_IPI2_MASTER {A72} \
      PS_GEN_IPI3_ENABLE {1} \
      PS_GEN_IPI3_MASTER {A72} \
      PS_GEN_IPI4_ENABLE {1} \
      PS_GEN_IPI4_MASTER {A72} \
      PS_GEN_IPI5_ENABLE {1} \
      PS_GEN_IPI5_MASTER {A72} \
      PS_GEN_IPI6_ENABLE {1} \
      PS_GEN_IPI6_MASTER {A72} \
      PS_GEN_IPI_PMCNOBUF_ENABLE {1} \
      PS_GEN_IPI_PMCNOBUF_MASTER {PMC} \
      PS_GEN_IPI_PMC_ENABLE {1} \
      PS_GEN_IPI_PMC_MASTER {PMC} \
      PS_GEN_IPI_PSM_ENABLE {1} \
      PS_GEN_IPI_PSM_MASTER {PSM} \
      PS_GPIO2_MIO_PERIPHERAL {{ENABLE 0} {IO {PS_MIO 0 .. 25}}} \
      PS_GPIO_EMIO_PERIPHERAL_ENABLE {1} \
      PS_GPIO_EMIO_WIDTH {32} \
      PS_HSDP0_REFCLK {0} \
      PS_HSDP1_REFCLK {0} \
      PS_HSDP_EGRESS_TRAFFIC {JTAG} \
      PS_HSDP_INGRESS_TRAFFIC {JTAG} \
      PS_HSDP_MODE {NONE} \
      PS_HSDP_SAME_EGRESS_AS_INGRESS_TRAFFIC {1} \
      PS_I2C0_PERIPHERAL {{ENABLE 0} {IO {PS_MIO 2 .. 3}}} \
      PS_I2C1_PERIPHERAL {{ENABLE 0} {IO {PS_MIO 0 .. 1}}} \
      PS_I2CSYSMON_PERIPHERAL {{ENABLE 0} {IO {PS_MIO 23 .. 24}}} \
      PS_IRQ_USAGE {{CH0 0} {CH1 0} {CH10 0} {CH11 0} {CH12 0} {CH13 0} {CH14 0} {CH15 0} {CH2 0} {CH3 0} {CH4 0} {CH5 0} {CH6 0} {CH7 0} {CH8 0} {CH9 0}} \
      PS_KAT_ENABLE {1} \
      PS_KAT_ENABLE_1 {1} \
      PS_KAT_ENABLE_2 {1} \
      PS_KAT_ENABLE_3 {1} \
      PS_LPDMA0_COHERENCY {0} \
      PS_LPDMA0_ROUTE_THROUGH_FPD {0} \
      PS_LPDMA1_COHERENCY {0} \
      PS_LPDMA1_ROUTE_THROUGH_FPD {0} \
      PS_LPDMA2_COHERENCY {0} \
      PS_LPDMA2_ROUTE_THROUGH_FPD {0} \
      PS_LPDMA3_COHERENCY {0} \
      PS_LPDMA3_ROUTE_THROUGH_FPD {0} \
      PS_LPDMA4_COHERENCY {0} \
      PS_LPDMA4_ROUTE_THROUGH_FPD {0} \
      PS_LPDMA5_COHERENCY {0} \
      PS_LPDMA5_ROUTE_THROUGH_FPD {0} \
      PS_LPDMA6_COHERENCY {0} \
      PS_LPDMA6_ROUTE_THROUGH_FPD {0} \
      PS_LPDMA7_COHERENCY {0} \
      PS_LPDMA7_ROUTE_THROUGH_FPD {0} \
      PS_LPD_DMA_CHANNEL_ENABLE {{CH0 0} {CH1 0} {CH2 0} {CH3 0} {CH4 0} {CH5 0} {CH6 0} {CH7 0}} \
      PS_LPD_DMA_CH_TZ {{CH0 NonSecure} {CH1 NonSecure} {CH2 NonSecure} {CH3 NonSecure} {CH4 NonSecure} {CH5 NonSecure} {CH6 NonSecure} {CH7 NonSecure}} \
      PS_LPD_DMA_ENABLE {0} \
      PS_LPD_INTERCONNECT_LOAD {90} \
      PS_MIO0 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO1 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO10 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO11 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO12 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO13 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO14 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO15 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO16 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO17 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO18 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PS_MIO19 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO2 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO20 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO21 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO22 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO23 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO24 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO25 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO3 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO4 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO5 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO6 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO7 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO8 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_MIO9 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} \
      PS_M_AXI_FPD_DATA_WIDTH {128} \
      PS_M_AXI_GP4_DATA_WIDTH {128} \
      PS_M_AXI_LPD_DATA_WIDTH {32} \
      PS_NOC_PS_CCI_DATA_WIDTH {128} \
      PS_NOC_PS_NCI_DATA_WIDTH {128} \
      PS_NOC_PS_PCI_DATA_WIDTH {128} \
      PS_NOC_PS_PMC_DATA_WIDTH {128} \
      PS_NUM_F2P0_INTR_INPUTS {1} \
      PS_NUM_F2P1_INTR_INPUTS {1} \
      PS_NUM_FABRIC_RESETS {0} \
      PS_OCM_ACTIVE_BLOCKS {1} \
      PS_PCIE1_PERIPHERAL_ENABLE {1} \
      PS_PCIE2_PERIPHERAL_ENABLE {0} \
      PS_PCIE_EP_RESET1_IO {PS_MIO 18} \
      PS_PCIE_EP_RESET2_IO {None} \
      PS_PCIE_PERIPHERAL_ENABLE {0} \
      PS_PCIE_RESET {ENABLE 1} \
      PS_PCIE_ROOT_RESET1_IO {None} \
      PS_PCIE_ROOT_RESET1_IO_DIR {output} \
      PS_PCIE_ROOT_RESET1_POLARITY {Active Low} \
      PS_PCIE_ROOT_RESET2_IO {None} \
      PS_PCIE_ROOT_RESET2_IO_DIR {output} \
      PS_PCIE_ROOT_RESET2_POLARITY {Active Low} \
      PS_PL_CONNECTIVITY_MODE {Custom} \
      PS_PL_DONE {0} \
      PS_PL_PASS_AXPROT_VALUE {0} \
      PS_PMCPL_CLK0_BUF {1} \
      PS_PMCPL_CLK1_BUF {1} \
      PS_PMCPL_CLK2_BUF {1} \
      PS_PMCPL_CLK3_BUF {1} \
      PS_PMCPL_IRO_CLK_BUF {1} \
      PS_PMU_PERIPHERAL_ENABLE {0} \
      PS_PS_ENABLE {0} \
      PS_PS_NOC_CCI_DATA_WIDTH {128} \
      PS_PS_NOC_NCI_DATA_WIDTH {128} \
      PS_PS_NOC_PCI_DATA_WIDTH {128} \
      PS_PS_NOC_PMC_DATA_WIDTH {128} \
      PS_PS_NOC_RPU_DATA_WIDTH {128} \
      PS_R5_ACTIVE_BLOCKS {2} \
      PS_R5_LOAD {90} \
      PS_RPU_COHERENCY {0} \
      PS_SLR_TYPE {master} \
      PS_SMON_PL_PORTS_ENABLE {0} \
      PS_SPI0 {{GRP_SS0_ENABLE 0} {GRP_SS0_IO {PMC_MIO 15}} {GRP_SS1_ENABLE 0} {GRP_SS1_IO {PMC_MIO 14}} {GRP_SS2_ENABLE 0} {GRP_SS2_IO {PMC_MIO 13}} {PERIPHERAL_ENABLE 0} {PERIPHERAL_IO {PMC_MIO 12 ..\
17}}} \
      PS_SPI1 {{GRP_SS0_ENABLE 0} {GRP_SS0_IO {PS_MIO 9}} {GRP_SS1_ENABLE 0} {GRP_SS1_IO {PS_MIO 8}} {GRP_SS2_ENABLE 0} {GRP_SS2_IO {PS_MIO 7}} {PERIPHERAL_ENABLE 0} {PERIPHERAL_IO {PS_MIO 6 .. 11}}} \
      PS_S_AXI_ACE_DATA_WIDTH {128} \
      PS_S_AXI_ACP_DATA_WIDTH {128} \
      PS_S_AXI_FPD_DATA_WIDTH {128} \
      PS_S_AXI_GP2_DATA_WIDTH {128} \
      PS_S_AXI_LPD_DATA_WIDTH {128} \
      PS_TCM_ACTIVE_BLOCKS {2} \
      PS_TIE_MJTAG_TCK_TO_GND {1} \
      PS_TRACE_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 30 .. 47}}} \
      PS_TRACE_WIDTH {2Bit} \
      PS_TRISTATE_INVERTED {1} \
      PS_TTC0_CLK {{ENABLE 0} {IO {PS_MIO 6}}} \
      PS_TTC0_PERIPHERAL_ENABLE {1} \
      PS_TTC0_REF_CTRL_ACT_FREQMHZ {150.000000} \
      PS_TTC0_REF_CTRL_FREQMHZ {150.000000} \
      PS_TTC0_WAVEOUT {{ENABLE 0} {IO {PS_MIO 7}}} \
      PS_TTC1_CLK {{ENABLE 0} {IO {PS_MIO 12}}} \
      PS_TTC1_PERIPHERAL_ENABLE {1} \
      PS_TTC1_REF_CTRL_ACT_FREQMHZ {150.000000} \
      PS_TTC1_REF_CTRL_FREQMHZ {150.000000} \
      PS_TTC1_WAVEOUT {{ENABLE 0} {IO {PS_MIO 13}}} \
      PS_TTC2_CLK {{ENABLE 0} {IO {PS_MIO 2}}} \
      PS_TTC2_PERIPHERAL_ENABLE {1} \
      PS_TTC2_REF_CTRL_ACT_FREQMHZ {150.000000} \
      PS_TTC2_REF_CTRL_FREQMHZ {150.000000} \
      PS_TTC2_WAVEOUT {{ENABLE 0} {IO {PS_MIO 3}}} \
      PS_TTC3_CLK {{ENABLE 0} {IO {PS_MIO 16}}} \
      PS_TTC3_PERIPHERAL_ENABLE {1} \
      PS_TTC3_REF_CTRL_ACT_FREQMHZ {150.000000} \
      PS_TTC3_REF_CTRL_FREQMHZ {150.000000} \
      PS_TTC3_WAVEOUT {{ENABLE 0} {IO {PS_MIO 17}}} \
      PS_TTC_APB_CLK_TTC0_SEL {APB} \
      PS_TTC_APB_CLK_TTC1_SEL {APB} \
      PS_TTC_APB_CLK_TTC2_SEL {APB} \
      PS_TTC_APB_CLK_TTC3_SEL {APB} \
      PS_UART0_BAUD_RATE {115200} \
      PS_UART0_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 26 .. 27}}} \
      PS_UART0_RTS_CTS {{ENABLE 0} {IO {PS_MIO 2 .. 3}}} \
      PS_UART1_BAUD_RATE {115200} \
      PS_UART1_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 4 .. 5}}} \
      PS_UART1_RTS_CTS {{ENABLE 0} {IO {PMC_MIO 6 .. 7}}} \
      PS_UNITS_MODE {Custom} \
      PS_USB3_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 13 .. 25}}} \
      PS_USB_COHERENCY {0} \
      PS_USB_ROUTE_THROUGH_FPD {0} \
      PS_USE_ACE_LITE {0} \
      PS_USE_APU_EVENT_BUS {0} \
      PS_USE_APU_INTERRUPT {0} \
      PS_USE_AXI4_EXT_USER_BITS {0} \
      PS_USE_BSCAN_USER1 {0} \
      PS_USE_BSCAN_USER2 {0} \
      PS_USE_BSCAN_USER3 {0} \
      PS_USE_BSCAN_USER4 {0} \
      PS_USE_CAPTURE {0} \
      PS_USE_CLK {0} \
      PS_USE_DEBUG_TEST {0} \
      PS_USE_DIFF_RW_CLK_S_AXI_FPD {0} \
      PS_USE_DIFF_RW_CLK_S_AXI_GP2 {0} \
      PS_USE_DIFF_RW_CLK_S_AXI_LPD {0} \
      PS_USE_ENET0_PTP {0} \
      PS_USE_ENET1_PTP {0} \
      PS_USE_FIFO_ENET0 {0} \
      PS_USE_FIFO_ENET1 {0} \
      PS_USE_FIXED_IO {0} \
      PS_USE_FPD_AXI_NOC0 {1} \
      PS_USE_FPD_AXI_NOC1 {0} \
      PS_USE_FPD_CCI_NOC {0} \
      PS_USE_FPD_CCI_NOC0 {0} \
      PS_USE_FPD_CCI_NOC1 {0} \
      PS_USE_FPD_CCI_NOC2 {0} \
      PS_USE_FPD_CCI_NOC3 {0} \
      PS_USE_FTM_GPI {0} \
      PS_USE_FTM_GPO {0} \
      PS_USE_HSDP_PL {0} \
      PS_USE_MJTAG_TCK_TIE_OFF {0} \
      PS_USE_M_AXI_FPD {0} \
      PS_USE_M_AXI_LPD {1} \
      PS_USE_NOC_FPD_AXI0 {0} \
      PS_USE_NOC_FPD_AXI1 {0} \
      PS_USE_NOC_FPD_CCI0 {0} \
      PS_USE_NOC_FPD_CCI1 {0} \
      PS_USE_NOC_LPD_AXI0 {0} \
      PS_USE_NOC_PS_PCI_0 {0} \
      PS_USE_NOC_PS_PMC_0 {0} \
      PS_USE_NPI_CLK {0} \
      PS_USE_NPI_RST {0} \
      PS_USE_PL_FPD_AUX_REF_CLK {0} \
      PS_USE_PL_LPD_AUX_REF_CLK {0} \
      PS_USE_PMC {0} \
      PS_USE_PMCPL_CLK0 {1} \
      PS_USE_PMCPL_CLK1 {1} \
      PS_USE_PMCPL_CLK2 {0} \
      PS_USE_PMCPL_CLK3 {0} \
      PS_USE_PMCPL_IRO_CLK {0} \
      PS_USE_PSPL_IRQ_FPD {0} \
      PS_USE_PSPL_IRQ_LPD {0} \
      PS_USE_PSPL_IRQ_PMC {0} \
      PS_USE_PS_NOC_PCI_0 {0} \
      PS_USE_PS_NOC_PCI_1 {0} \
      PS_USE_PS_NOC_PMC_0 {0} \
      PS_USE_PS_NOC_PMC_1 {0} \
      PS_USE_RPU_EVENT {0} \
      PS_USE_RPU_INTERRUPT {0} \
      PS_USE_RTC {0} \
      PS_USE_SMMU {0} \
      PS_USE_STARTUP {0} \
      PS_USE_STM {0} \
      PS_USE_S_ACP_FPD {0} \
      PS_USE_S_AXI_ACE {0} \
      PS_USE_S_AXI_FPD {0} \
      PS_USE_S_AXI_GP2 {0} \
      PS_USE_S_AXI_LPD {0} \
      PS_USE_TRACE_ATB {0} \
      PS_WDT0_REF_CTRL_ACT_FREQMHZ {100} \
      PS_WDT0_REF_CTRL_FREQMHZ {100} \
      PS_WDT0_REF_CTRL_SEL {NONE} \
      PS_WDT1_REF_CTRL_ACT_FREQMHZ {100} \
      PS_WDT1_REF_CTRL_FREQMHZ {100} \
      PS_WDT1_REF_CTRL_SEL {NONE} \
      PS_WWDT0_CLK {{ENABLE 0} {IO {PMC_MIO 0}}} \
      PS_WWDT0_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 0 .. 5}}} \
      PS_WWDT1_CLK {{ENABLE 0} {IO {PMC_MIO 6}}} \
      PS_WWDT1_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 6 .. 11}}} \
      SEM_MEM_SCAN {1} \
      SEM_NPI_SCAN {1} \
      SLR1_PMC_CRP_HSM0_REF_CTRL_ACT_FREQMHZ {200.000000} \
      SLR1_PMC_CRP_HSM0_REF_CTRL_DIVISOR0 {6} \
      SLR1_PMC_CRP_HSM0_REF_CTRL_FREQMHZ {200} \
      SLR1_PMC_CRP_HSM0_REF_CTRL_SRCSEL {PPLL} \
      SLR1_PMC_CRP_HSM1_REF_CTRL_ACT_FREQMHZ {33.33} \
      SLR1_PMC_CRP_HSM1_REF_CTRL_DIVISOR0 {36} \
      SLR1_PMC_CRP_HSM1_REF_CTRL_FREQMHZ {33.333} \
      SLR1_PMC_CRP_HSM1_REF_CTRL_SRCSEL {PPLL} \
      SLR1_PMC_HSM0_CLK_ENABLE {1} \
      SLR1_PMC_HSM0_CLK_OUT_ENABLE {0} \
      SLR1_PMC_HSM1_CLK_ENABLE {1} \
      SLR1_PMC_HSM1_CLK_OUT_ENABLE {0} \
      SLR1_PS_USE_CAPTURE {0} \
      SLR2_PMC_CRP_HSM0_REF_CTRL_ACT_FREQMHZ {99.999} \
      SLR2_PMC_CRP_HSM0_REF_CTRL_DIVISOR0 {12} \
      SLR2_PMC_CRP_HSM0_REF_CTRL_FREQMHZ {100} \
      SLR2_PMC_CRP_HSM0_REF_CTRL_SRCSEL {PPLL} \
      SLR2_PMC_CRP_HSM1_REF_CTRL_ACT_FREQMHZ {33.33} \
      SLR2_PMC_CRP_HSM1_REF_CTRL_DIVISOR0 {36} \
      SLR2_PMC_CRP_HSM1_REF_CTRL_FREQMHZ {33.333} \
      SLR2_PMC_CRP_HSM1_REF_CTRL_SRCSEL {PPLL} \
      SLR2_PMC_HSM0_CLK_ENABLE {1} \
      SLR2_PMC_HSM0_CLK_OUT_ENABLE {0} \
      SLR2_PMC_HSM1_CLK_ENABLE {1} \
      SLR2_PMC_HSM1_CLK_OUT_ENABLE {0} \
      SLR2_PS_USE_CAPTURE {0} \
      SLR3_PMC_CRP_HSM0_REF_CTRL_ACT_FREQMHZ {99.999} \
      SLR3_PMC_CRP_HSM0_REF_CTRL_DIVISOR0 {12} \
      SLR3_PMC_CRP_HSM0_REF_CTRL_FREQMHZ {100} \
      SLR3_PMC_CRP_HSM0_REF_CTRL_SRCSEL {PPLL} \
      SLR3_PMC_CRP_HSM1_REF_CTRL_ACT_FREQMHZ {33.33} \
      SLR3_PMC_CRP_HSM1_REF_CTRL_DIVISOR0 {36} \
      SLR3_PMC_CRP_HSM1_REF_CTRL_FREQMHZ {33.333} \
      SLR3_PMC_CRP_HSM1_REF_CTRL_SRCSEL {PPLL} \
      SLR3_PMC_HSM0_CLK_ENABLE {1} \
      SLR3_PMC_HSM0_CLK_OUT_ENABLE {0} \
      SLR3_PMC_HSM1_CLK_ENABLE {1} \
      SLR3_PMC_HSM1_CLK_OUT_ENABLE {0} \
      SLR3_PS_USE_CAPTURE {0} \
      SMON_ALARMS {Set_Alarms_On} \
      SMON_ENABLE_INT_VOLTAGE_MONITORING {0} \
      SMON_ENABLE_TEMP_AVERAGING {0} \
      SMON_HI_PERF_MODE {1} \
      SMON_INTERFACE_TO_USE {None} \
      SMON_INT_MEASUREMENT_ALARM_ENABLE {0} \
      SMON_INT_MEASUREMENT_AVG_ENABLE {0} \
      SMON_INT_MEASUREMENT_ENABLE {0} \
      SMON_INT_MEASUREMENT_MODE {0} \
      SMON_INT_MEASUREMENT_TH_HIGH {0} \
      SMON_INT_MEASUREMENT_TH_LOW {0} \
      SMON_MEAS0 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVCCAUX_202} {SUPPLY_NUM 52}} \
      SMON_MEAS1 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVCCAUX_203} {SUPPLY_NUM 53}} \
      SMON_MEAS10 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVTT_202} {SUPPLY_NUM 47}} \
      SMON_MEAS100 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS101 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS102 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS103 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS104 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS105 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS106 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS107 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS108 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS109 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS11 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVTT_203} {SUPPLY_NUM 48}} \
      SMON_MEAS110 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS111 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS112 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS113 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS114 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS115 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS116 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS117 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS118 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS119 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS12 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVTT_204} {SUPPLY_NUM 49}} \
      SMON_MEAS120 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS121 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS122 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS123 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS124 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS125 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS126 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS127 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS128 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS129 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS13 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVTT_205} {SUPPLY_NUM 50}} \
      SMON_MEAS130 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS131 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS132 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS133 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS134 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS135 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS136 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS137 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS138 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS139 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS14 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVTT_206} {SUPPLY_NUM 51}} \
      SMON_MEAS140 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS141 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS142 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS143 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS144 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS145 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS146 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS147 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS148 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS149 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS15 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_102} {SUPPLY_NUM 57}} \
      SMON_MEAS150 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS151 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS152 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS153 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS154 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS155 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS156 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS157 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS158 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS159 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS16 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_103} {SUPPLY_NUM 58}} \
      SMON_MEAS160 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} \
      SMON_MEAS161 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} \
      SMON_MEAS162 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE {2 V unipolar}} {NAME VCCINT}} \
      SMON_MEAS163 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE {2 V unipolar}} {NAME VCCAUX}} \
      SMON_MEAS164 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE {2 V unipolar}} {NAME VCC_RAM}} \
      SMON_MEAS165 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE {2 V unipolar}} {NAME VCC_SOC}} \
      SMON_MEAS166 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE {2 V unipolar}} {NAME VCC_PSFP}} \
      SMON_MEAS167 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE {2 V unipolar}} {NAME VCC_PSLP}} \
      SMON_MEAS168 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE {2 V unipolar}} {NAME VCCAUX_PMC}} \
      SMON_MEAS169 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE {2 V unipolar}} {NAME VCC_PMC}} \
      SMON_MEAS17 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_104} {SUPPLY_NUM 59}} \
      SMON_MEAS170 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} \
      SMON_MEAS171 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} \
      SMON_MEAS172 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} \
      SMON_MEAS173 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} \
      SMON_MEAS174 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} \
      SMON_MEAS175 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} \
      SMON_MEAS18 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_105} {SUPPLY_NUM 60}} \
      SMON_MEAS19 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_106} {SUPPLY_NUM 61}} \
      SMON_MEAS2 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVCCAUX_204} {SUPPLY_NUM 54}} \
      SMON_MEAS20 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_109} {SUPPLY_NUM 84}} \
      SMON_MEAS21 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_110} {SUPPLY_NUM 85}} \
      SMON_MEAS22 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_111} {SUPPLY_NUM 86}} \
      SMON_MEAS23 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_112} {SUPPLY_NUM 87}} \
      SMON_MEAS24 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_200} {SUPPLY_NUM 62}} \
      SMON_MEAS25 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_201} {SUPPLY_NUM 63}} \
      SMON_MEAS26 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_207} {SUPPLY_NUM 88}} \
      SMON_MEAS27 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_208} {SUPPLY_NUM 89}} \
      SMON_MEAS28 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_209} {SUPPLY_NUM 90}} \
      SMON_MEAS29 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_210} {SUPPLY_NUM 91}} \
      SMON_MEAS3 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVCCAUX_205} {SUPPLY_NUM 55}} \
      SMON_MEAS30 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_211} {SUPPLY_NUM 92}} \
      SMON_MEAS31 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_212} {SUPPLY_NUM 93}} \
      SMON_MEAS32 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_102} {SUPPLY_NUM 40}} \
      SMON_MEAS33 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_103} {SUPPLY_NUM 41}} \
      SMON_MEAS34 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_104} {SUPPLY_NUM 42}} \
      SMON_MEAS35 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_105} {SUPPLY_NUM 43}} \
      SMON_MEAS36 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_106} {SUPPLY_NUM 44}} \
      SMON_MEAS37 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_109} {SUPPLY_NUM 74}} \
      SMON_MEAS38 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_110} {SUPPLY_NUM 75}} \
      SMON_MEAS39 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_111} {SUPPLY_NUM 76}} \
      SMON_MEAS4 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVCCAUX_206} {SUPPLY_NUM 56}} \
      SMON_MEAS40 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_112} {SUPPLY_NUM 77}} \
      SMON_MEAS41 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_200} {SUPPLY_NUM 45}} \
      SMON_MEAS42 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_201} {SUPPLY_NUM 46}} \
      SMON_MEAS43 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_207} {SUPPLY_NUM 78}} \
      SMON_MEAS44 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_208} {SUPPLY_NUM 79}} \
      SMON_MEAS45 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_209} {SUPPLY_NUM 80}} \
      SMON_MEAS46 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_210} {SUPPLY_NUM 81}} \
      SMON_MEAS47 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_211} {SUPPLY_NUM 82}} \
      SMON_MEAS48 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_212} {SUPPLY_NUM 83}} \
      SMON_MEAS49 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_102} {SUPPLY_NUM 28}} \
      SMON_MEAS5 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVCC_202} {SUPPLY_NUM 35}} \
      SMON_MEAS50 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_103} {SUPPLY_NUM 29}} \
      SMON_MEAS51 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_104} {SUPPLY_NUM 30}} \
      SMON_MEAS52 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_105} {SUPPLY_NUM 31}} \
      SMON_MEAS53 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_106} {SUPPLY_NUM 32}} \
      SMON_MEAS54 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_109} {SUPPLY_NUM 64}} \
      SMON_MEAS55 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_110} {SUPPLY_NUM 65}} \
      SMON_MEAS56 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_111} {SUPPLY_NUM 66}} \
      SMON_MEAS57 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_112} {SUPPLY_NUM 67}} \
      SMON_MEAS58 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_200} {SUPPLY_NUM 33}} \
      SMON_MEAS59 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_201} {SUPPLY_NUM 34}} \
      SMON_MEAS6 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVCC_203} {SUPPLY_NUM 36}} \
      SMON_MEAS60 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_207} {SUPPLY_NUM 68}} \
      SMON_MEAS61 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 1.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_208} {SUPPLY_NUM 69}} \
      SMON_MEAS62 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_209} {SUPPLY_NUM 70}} \
      SMON_MEAS63 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_210} {SUPPLY_NUM 71}} \
      SMON_MEAS64 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_211} {SUPPLY_NUM 72}} \
      SMON_MEAS65 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_212} {SUPPLY_NUM 73}} \
      SMON_MEAS66 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX} {SUPPLY_NUM 0}} \
      SMON_MEAS67 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX_PMC} {SUPPLY_NUM 1}} \
      SMON_MEAS68 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX_SMON} {SUPPLY_NUM 10}} \
      SMON_MEAS69 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCINT} {SUPPLY_NUM 9}} \
      SMON_MEAS7 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVCC_204} {SUPPLY_NUM 37}} \
      SMON_MEAS70 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_500} {SUPPLY_NUM 11}} \
      SMON_MEAS71 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_501} {SUPPLY_NUM 12}} \
      SMON_MEAS72 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_502} {SUPPLY_NUM 13}} \
      SMON_MEAS73 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_503} {SUPPLY_NUM 14}} \
      SMON_MEAS74 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_700} {SUPPLY_NUM 15}} \
      SMON_MEAS75 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_701} {SUPPLY_NUM 16}} \
      SMON_MEAS76 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_702} {SUPPLY_NUM 17}} \
      SMON_MEAS77 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_703} {SUPPLY_NUM 18}} \
      SMON_MEAS78 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_704} {SUPPLY_NUM 19}} \
      SMON_MEAS79 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_705} {SUPPLY_NUM 20}} \
      SMON_MEAS8 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVCC_205} {SUPPLY_NUM 38}} \
      SMON_MEAS80 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_706} {SUPPLY_NUM 21}} \
      SMON_MEAS81 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_707} {SUPPLY_NUM 22}} \
      SMON_MEAS82 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_708} {SUPPLY_NUM 23}} \
      SMON_MEAS83 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_709} {SUPPLY_NUM 24}} \
      SMON_MEAS84 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_710} {SUPPLY_NUM 25}} \
      SMON_MEAS85 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_711} {SUPPLY_NUM 26}} \
      SMON_MEAS86 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_712} {SUPPLY_NUM 27}} \
      SMON_MEAS87 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_BATT} {SUPPLY_NUM 7}} \
      SMON_MEAS88 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PMC} {SUPPLY_NUM 2}} \
      SMON_MEAS89 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PSFP} {SUPPLY_NUM 3}} \
      SMON_MEAS9 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTM_AVCC_206} {SUPPLY_NUM 39}} \
      SMON_MEAS90 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PSLP} {SUPPLY_NUM 4}} \
      SMON_MEAS91 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_RAM} {SUPPLY_NUM 8}} \
      SMON_MEAS92 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_SOC} {SUPPLY_NUM 5}} \
      SMON_MEAS93 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 1.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VP_VN} {SUPPLY_NUM 6}} \
      SMON_MEAS94 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS95 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS96 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS97 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS98 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEAS99 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103} {SUPPLY_NUM 0}} \
      SMON_MEASUREMENT_COUNT {94} \
      SMON_MEASUREMENT_LIST {BANK_VOLTAGE:GTM_AVTT-GTM_AVTT_202,GTM_AVTT_203,GTM_AVTT_204,GTM_AVTT_205,GTM_AVTT_206#GTYP_AVTT-GTYP_AVTT_102,GTYP_AVTT_103,GTYP_AVTT_104,GTYP_AVTT_105,GTYP_AVTT_106,GTYP_AVTT_109,GTYP_AVTT_110,GTYP_AVTT_111,GTYP_AVTT_112,GTYP_AVTT_200,GTYP_AVTT_201,GTYP_AVTT_207,GTYP_AVTT_208,GTYP_AVTT_209,GTYP_AVTT_210,GTYP_AVTT_211,GTYP_AVTT_212#VCC-GTM_AVCC_202,GTM_AVCC_203,GTM_AVCC_204,GTM_AVCC_205,GTM_AVCC_206,GTYP_AVCC_102,GTYP_AVCC_103,GTYP_AVCC_104,GTYP_AVCC_105,GTYP_AVCC_106,GTYP_AVCC_109,GTYP_AVCC_110,GTYP_AVCC_111,GTYP_AVCC_112,GTYP_AVCC_200,GTYP_AVCC_201,GTYP_AVCC_207,GTYP_AVCC_208,GTYP_AVCC_209,GTYP_AVCC_210,GTYP_AVCC_211,GTYP_AVCC_212#VCCAUX-GTM_AVCCAUX_202,GTM_AVCCAUX_203,GTM_AVCCAUX_204,GTM_AVCCAUX_205,GTM_AVCCAUX_206,GTYP_AVCCAUX_102,GTYP_AVCCAUX_103,GTYP_AVCCAUX_104,GTYP_AVCCAUX_105,GTYP_AVCCAUX_106,GTYP_AVCCAUX_109,GTYP_AVCCAUX_110,GTYP_AVCCAUX_111,GTYP_AVCCAUX_112,GTYP_AVCCAUX_200,GTYP_AVCCAUX_201,GTYP_AVCCAUX_207,GTYP_AVCCAUX_208,GTYP_AVCCAUX_209,GTYP_AVCCAUX_210,GTYP_AVCCAUX_211,GTYP_AVCCAUX_212#VCCO-VCCO_500,VCCO_501,VCCO_502,VCCO_503,VCCO_700,VCCO_701,VCCO_702,VCCO_703,VCCO_704,VCCO_705,VCCO_706,VCCO_707,VCCO_708,VCCO_709,VCCO_710,VCCO_711,VCCO_712|DEDICATED_PAD:VP-VP_VN|SUPPLY_VOLTAGE:VCC-VCC_BATT,VCC_PMC,VCC_PSFP,VCC_PSLP,VCC_RAM,VCC_SOC#VCCAUX-VCCAUX,VCCAUX_PMC,VCCAUX_SMON#VCCINT-VCCINT}\
\
      SMON_MUX_ADDR_ENABLE {0} \
      SMON_OT {{THRESHOLD_LOWER 70} {THRESHOLD_UPPER 125}} \
      SMON_PMBUS_ADDRESS {0x0} \
      SMON_PMBUS_UNRESTRICTED {0} \
      SMON_REFERENCE_SOURCE {Internal} \
      SMON_TEMP_AVERAGING_SAMPLES {0} \
      SMON_TEMP_THRESHOLD {0} \
      SMON_USER_TEMP {{THRESHOLD_LOWER 70} {THRESHOLD_UPPER 125} {USER_ALARM_TYPE hysteresis}} \
      SMON_VAUX_CH0 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH0} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH1 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH1} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH10 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH10} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH11 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH11} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH12 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH12} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH13 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH13} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH14 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH14} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH15 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH15} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH2 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH2} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH3 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH3} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH4 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH4} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH5 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH5} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH6 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH6} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH7 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH7} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH8 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH8} {SUPPLY_NUM 0}} \
      SMON_VAUX_CH9 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE {1 V unipolar}} {NAME VAUX_CH9} {SUPPLY_NUM 0}} \
      SMON_VAUX_IO_BANK {MIO_BANK0} \
      SMON_VOLTAGE_AVERAGING_SAMPLES {None} \
      SPP_PSPMC_FROM_CORE_WIDTH {12000} \
      SPP_PSPMC_TO_CORE_WIDTH {12000} \
      SUBPRESET1 {Custom} \
      USE_UART0_IN_DEVICE_BOOT {0} \
      preset {None} \
    } \
    CONFIG.PS_PMC_CONFIG_APPLIED {1} \
  ] $versal_cips_0


  # Create instance: axi_noc_0, and set properties
  set axi_noc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 axi_noc_0 ]
  set_property -dict [list \
    CONFIG.BLI_DESTID_PINS {} \
    CONFIG.CLK_NAMES {} \
    CONFIG.HBM_CHNL0_CONFIG {HBM_REF_PERIOD_TEMP_COMP FALSE} \
    CONFIG.HBM_SIDEBAND_PINS {} \
    CONFIG.HBM_STACK0_CONFIG { } \
    CONFIG.MI_INFO_PINS {} \
    CONFIG.MI_NAMES {} \
    CONFIG.MI_SIDEBAND_PINS {} \
    CONFIG.MI_USR_INTR_PINS {} \
    CONFIG.NMI_NAMES {} \
    CONFIG.NOC_RD_RATE {} \
    CONFIG.NOC_WR_RATE {} \
    CONFIG.NSI_NAMES {} \
    CONFIG.NUM_CLKS {8} \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_NMI {5} \
    CONFIG.NUM_NSI {0} \
    CONFIG.NUM_SI {6} \
    CONFIG.SI_DESTID_PINS {} \
    CONFIG.SI_NAMES {} \
    CONFIG.SI_SIDEBAND_PINS {} \
    CONFIG.SI_USR_INTR_PINS {} \
  ] $axi_noc_0


  set_property -dict [ list \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins $axi_noc_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.CATEGORY {ps_pcie} \
 ] [get_bd_intf_pins $axi_noc_0/M01_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M01_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M00_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}} M00_INI {read_bw {500} write_bw {500}}} \
   CONFIG.DEST_IDS {M01_AXI:0x140:M00_AXI:0x1} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_nci} \
 ] [get_bd_intf_pins $axi_noc_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M01_INI {read_bw {500} write_bw {500}} M00_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x1} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc_0/S01_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500}} M00_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x1} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc_0/S02_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M03_INI {read_bw {500} write_bw {500}} M00_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x1} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc_0/S03_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M04_INI {read_bw {500} write_bw {500}} M00_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x1} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc_0/S04_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x1} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pcie} \
 ] [get_bd_intf_pins $axi_noc_0/S05_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk4]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S04_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk5]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S05_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk6]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M01_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk7]

  # Create instance: axi_noc_1, and set properties
  set axi_noc_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 axi_noc_1 ]
  set_property -dict [list \
    CONFIG.BLI_DESTID_PINS {} \
    CONFIG.CLK_NAMES {} \
    CONFIG.HBM_CHNL0_CONFIG {HBM_REF_PERIOD_TEMP_COMP FALSE} \
    CONFIG.HBM_SIDEBAND_PINS {} \
    CONFIG.HBM_STACK0_CONFIG { } \
    CONFIG.MI_INFO_PINS {} \
    CONFIG.MI_NAMES {} \
    CONFIG.MI_SIDEBAND_PINS {} \
    CONFIG.MI_USR_INTR_PINS {} \
    CONFIG.NMI_NAMES {} \
    CONFIG.NOC_RD_RATE {} \
    CONFIG.NOC_WR_RATE {} \
    CONFIG.NSI_NAMES {} \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_NMI {0} \
    CONFIG.NUM_NSI {5} \
    CONFIG.NUM_SI {1} \
    CONFIG.SI_DESTID_PINS {} \
    CONFIG.SI_NAMES {} \
    CONFIG.SI_SIDEBAND_PINS {} \
    CONFIG.SI_USR_INTR_PINS {} \
  ] $axi_noc_1


  set_property -dict [ list \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins $axi_noc_1/M00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x401} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pcie} \
 ] [get_bd_intf_pins $axi_noc_1/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins $axi_noc_1/S00_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins $axi_noc_1/S01_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins $axi_noc_1/S02_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins $axi_noc_1/S03_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins $axi_noc_1/S04_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins $axi_noc_1/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins $axi_noc_1/aclk1]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_noc_0_M00_AXI [get_bd_intf_pins axi_noc_0/M00_AXI] [get_bd_intf_pins versal_cips_0/NOC_PMC_AXI_0]
  connect_bd_intf_net -intf_net axi_noc_0_M00_INI [get_bd_intf_pins axi_noc_0/M00_INI] [get_bd_intf_pins axi_noc_1/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_0_M01_AXI [get_bd_intf_pins versal_cips_0/NOC_CPM_PCIE_0] [get_bd_intf_pins axi_noc_0/M01_AXI]
  connect_bd_intf_net -intf_net axi_noc_0_M01_INI [get_bd_intf_pins axi_noc_0/M01_INI] [get_bd_intf_pins axi_noc_1/S01_INI]
  connect_bd_intf_net -intf_net axi_noc_0_M02_INI [get_bd_intf_pins axi_noc_1/S02_INI] [get_bd_intf_pins axi_noc_0/M02_INI]
  connect_bd_intf_net -intf_net axi_noc_0_M03_INI [get_bd_intf_pins axi_noc_0/M03_INI] [get_bd_intf_pins axi_noc_1/S03_INI]
  connect_bd_intf_net -intf_net axi_noc_0_M04_INI [get_bd_intf_pins axi_noc_1/S04_INI] [get_bd_intf_pins axi_noc_0/M04_INI]
  connect_bd_intf_net -intf_net axi_noc_1_M00_AXI [get_bd_intf_pins versal_cips_0/NOC_PMC_AXI_1] [get_bd_intf_pins axi_noc_1/M00_AXI]
  connect_bd_intf_net -intf_net gt_refclk0_0_1 [get_bd_intf_ports pcie_refclk] [get_bd_intf_pins versal_cips_0/gt_refclk0]
  connect_bd_intf_net -intf_net pcie0_cfg_control_0_1 [get_bd_intf_ports pcie_cfg_control] [get_bd_intf_pins versal_cips_0/pcie0_cfg_control]
  connect_bd_intf_net -intf_net pcie0_cfg_interrupt_0_1 [get_bd_intf_ports pcie_cfg_interrupt] [get_bd_intf_pins versal_cips_0/pcie0_cfg_interrupt]
  connect_bd_intf_net -intf_net pcie0_s_axis_cc_0_1 [get_bd_intf_ports pcie_s_axis_cc] [get_bd_intf_pins versal_cips_0/pcie0_s_axis_cc]
  connect_bd_intf_net -intf_net pcie0_s_axis_rq_0_1 [get_bd_intf_ports pcie_s_axis_rq] [get_bd_intf_pins versal_cips_0/pcie0_s_axis_rq]
  connect_bd_intf_net -intf_net s_axi_pmc0_1 [get_bd_intf_ports s_axi_pmc0] [get_bd_intf_pins axi_noc_0/S01_AXI]
  connect_bd_intf_net -intf_net s_axi_pmc1_1 [get_bd_intf_ports s_axi_pmc1] [get_bd_intf_pins axi_noc_0/S02_AXI]
  connect_bd_intf_net -intf_net s_axi_pmc2_1 [get_bd_intf_ports s_axi_pmc2] [get_bd_intf_pins axi_noc_0/S03_AXI]
  connect_bd_intf_net -intf_net s_axi_pmc3_1 [get_bd_intf_ports s_axi_pmc3] [get_bd_intf_pins axi_noc_0/S04_AXI]
  connect_bd_intf_net -intf_net versal_cips_0_CPM_PCIE_NOC_0 [get_bd_intf_pins axi_noc_0/S05_AXI] [get_bd_intf_pins versal_cips_0/CPM_PCIE_NOC_0]
  connect_bd_intf_net -intf_net versal_cips_0_CPM_PCIE_NOC_1 [get_bd_intf_pins versal_cips_0/CPM_PCIE_NOC_1] [get_bd_intf_pins axi_noc_1/S00_AXI]
  connect_bd_intf_net -intf_net versal_cips_0_FPD_AXI_NOC_0 [get_bd_intf_pins axi_noc_0/S00_AXI] [get_bd_intf_pins versal_cips_0/FPD_AXI_NOC_0]
  connect_bd_intf_net -intf_net versal_cips_0_M_AXI_LPD [get_bd_intf_ports m_axi_lpd] [get_bd_intf_pins versal_cips_0/M_AXI_LPD]
  connect_bd_intf_net -intf_net versal_cips_0_PCIE0_GT [get_bd_intf_ports pcie_gt] [get_bd_intf_pins versal_cips_0/PCIE0_GT]
  connect_bd_intf_net -intf_net versal_cips_0_pcie0_cfg_status [get_bd_intf_ports pcie_cfg_status] [get_bd_intf_pins versal_cips_0/pcie0_cfg_status]
  connect_bd_intf_net -intf_net versal_cips_0_pcie0_m_axis_cq [get_bd_intf_ports pcie_m_axis_cq] [get_bd_intf_pins versal_cips_0/pcie0_m_axis_cq]
  connect_bd_intf_net -intf_net versal_cips_0_pcie0_m_axis_rc [get_bd_intf_ports pcie_m_axis_rc] [get_bd_intf_pins versal_cips_0/pcie0_m_axis_rc]

  # Create port connections
  connect_bd_net -net LPD_GPIO_i_0_1  [get_bd_ports ps_lpd_gpi] \
  [get_bd_pins versal_cips_0/LPD_GPIO_i]
  connect_bd_net -net cpm_irq0_0_1  [get_bd_ports cpm_irq0] \
  [get_bd_pins versal_cips_0/cpm_irq0]
  connect_bd_net -net cpm_irq1_0_1  [get_bd_ports cpm_irq1] \
  [get_bd_pins versal_cips_0/cpm_irq1]
  connect_bd_net -net m_axi_lpd_aclk_0_1  [get_bd_ports m_axi_lpd_clk] \
  [get_bd_pins versal_cips_0/m_axi_lpd_aclk]
  connect_bd_net -net s_axi_pmc0_clk_1  [get_bd_ports s_axi_pmc0_clk] \
  [get_bd_pins axi_noc_0/aclk2]
  connect_bd_net -net s_axi_pmc1_clk_1  [get_bd_ports s_axi_pmc1_clk] \
  [get_bd_pins axi_noc_0/aclk3]
  connect_bd_net -net s_axi_pmc2_clk_1  [get_bd_ports s_axi_pmc2_clk] \
  [get_bd_pins axi_noc_0/aclk4]
  connect_bd_net -net s_axi_pmc3_clk_1  [get_bd_ports s_axi_pmc3_clk] \
  [get_bd_pins axi_noc_0/aclk5]
  connect_bd_net -net versal_cips_0_LPD_GPIO_o  [get_bd_pins versal_cips_0/LPD_GPIO_o] \
  [get_bd_ports ps_lpd_gpo]
  connect_bd_net -net versal_cips_0_cpm_cor_irq  [get_bd_pins versal_cips_0/cpm_cor_irq] \
  [get_bd_ports cpm_cor_irq]
  connect_bd_net -net versal_cips_0_cpm_misc_irq  [get_bd_pins versal_cips_0/cpm_misc_irq] \
  [get_bd_ports cpm_misc_irq]
  connect_bd_net -net versal_cips_0_cpm_pcie_noc_axi0_clk  [get_bd_pins versal_cips_0/cpm_pcie_noc_axi0_clk] \
  [get_bd_pins axi_noc_0/aclk6]
  connect_bd_net -net versal_cips_0_cpm_pcie_noc_axi1_clk  [get_bd_pins versal_cips_0/cpm_pcie_noc_axi1_clk] \
  [get_bd_pins axi_noc_1/aclk1]
  connect_bd_net -net versal_cips_0_cpm_uncor_irq  [get_bd_pins versal_cips_0/cpm_uncor_irq] \
  [get_bd_ports cpm_uncor_irq]
  connect_bd_net -net versal_cips_0_fpd_axi_noc_axi0_clk  [get_bd_pins versal_cips_0/fpd_axi_noc_axi0_clk] \
  [get_bd_pins axi_noc_0/aclk1]
  connect_bd_net -net versal_cips_0_noc_cpm_pcie_axi0_clk  [get_bd_pins versal_cips_0/noc_cpm_pcie_axi0_clk] \
  [get_bd_pins axi_noc_0/aclk7]
  connect_bd_net -net versal_cips_0_noc_pmc_axi_axi0_clk  [get_bd_pins versal_cips_0/noc_pmc_axi_axi0_clk] \
  [get_bd_pins axi_noc_0/aclk0]
  connect_bd_net -net versal_cips_0_noc_pmc_axi_axi1_clk  [get_bd_pins versal_cips_0/noc_pmc_axi_axi1_clk] \
  [get_bd_pins axi_noc_1/aclk0]
  connect_bd_net -net versal_cips_0_pcie0_user_clk  [get_bd_pins versal_cips_0/pcie0_user_clk] \
  [get_bd_ports pcie_user_clk]
  connect_bd_net -net versal_cips_0_pcie0_user_lnk_up  [get_bd_pins versal_cips_0/pcie0_user_lnk_up] \
  [get_bd_ports pcie_user_lnk_up]
  connect_bd_net -net versal_cips_0_pcie0_user_reset  [get_bd_pins versal_cips_0/pcie0_user_reset] \
  [get_bd_ports pcie_user_reset]
  connect_bd_net -net versal_cips_0_pl0_ref_clk  [get_bd_pins versal_cips_0/pl0_ref_clk] \
  [get_bd_ports pl0_refclk]
  connect_bd_net -net versal_cips_0_pl1_ref_clk  [get_bd_pins versal_cips_0/pl1_ref_clk] \
  [get_bd_ports pl1_refclk]

  # Create address segments
  assign_bd_address -offset 0xFFA80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_0] -force
  assign_bd_address -offset 0xFFA90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_1] -force
  assign_bd_address -offset 0xFFAA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_2] -force
  assign_bd_address -offset 0xFFAB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_3] -force
  assign_bd_address -offset 0xFFAC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_4] -force
  assign_bd_address -offset 0xFFAD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_5] -force
  assign_bd_address -offset 0xFFAE0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_6] -force
  assign_bd_address -offset 0xFFAF0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_7] -force
  assign_bd_address -offset 0x000100800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_0] -force
  assign_bd_address -offset 0x000100D10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_cti] -force
  assign_bd_address -offset 0x000100D00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_dbg] -force
  assign_bd_address -offset 0x000100D30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_etm] -force
  assign_bd_address -offset 0x000100D20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_pmu] -force
  assign_bd_address -offset 0x000100D50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_cti] -force
  assign_bd_address -offset 0x000100D40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_dbg] -force
  assign_bd_address -offset 0x000100D70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_etm] -force
  assign_bd_address -offset 0x000100D60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_pmu] -force
  assign_bd_address -offset 0x000100CA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_cti] -force
  assign_bd_address -offset 0x000100C60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_ela] -force
  assign_bd_address -offset 0x000100C30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_etf] -force
  assign_bd_address -offset 0x000100C20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_fun] -force
  assign_bd_address -offset 0x000100F80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_atm] -force
  assign_bd_address -offset 0x000100FA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2a] -force
  assign_bd_address -offset 0x000100FD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2d] -force
  assign_bd_address -offset 0x000100F40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2a] -force
  assign_bd_address -offset 0x000100F50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2b] -force
  assign_bd_address -offset 0x000100F60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2c] -force
  assign_bd_address -offset 0x000100F70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2d] -force
  assign_bd_address -offset 0x000100F20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_fun] -force
  assign_bd_address -offset 0x000100F00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_rom] -force
  assign_bd_address -offset 0x000100B80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_atm] -force
  assign_bd_address -offset 0x000100BB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1b] -force
  assign_bd_address -offset 0x000100BC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1c] -force
  assign_bd_address -offset 0x000100BD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1d] -force
  assign_bd_address -offset 0x000100B70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_stm] -force
  assign_bd_address -offset 0x000100980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_lpd_atm] -force
  assign_bd_address -offset 0x0001009D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_lpd_cti] -force
  assign_bd_address -offset 0x0001008D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_pmc_cti] -force
  assign_bd_address -offset 0x000100A10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_r50_cti] -force
  assign_bd_address -offset 0x000100A50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_r51_cti] -force
  assign_bd_address -offset 0xFC000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_cpm] -force
  assign_bd_address -offset 0xFF5E0000 -range 0x00300000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crl_0] -force
  assign_bd_address -offset 0x000101260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crp_0] -force
  assign_bd_address -offset 0xFF0B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_gpio_2] -force
  assign_bd_address -offset 0xFF330000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_0] -force
  assign_bd_address -offset 0xFF340000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_1] -force
  assign_bd_address -offset 0xFF350000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_2] -force
  assign_bd_address -offset 0xFF360000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_3] -force
  assign_bd_address -offset 0xFF370000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_4] -force
  assign_bd_address -offset 0xFF380000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_5] -force
  assign_bd_address -offset 0xFF3A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_6] -force
  assign_bd_address -offset 0xFF320000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc] -force
  assign_bd_address -offset 0xFF390000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc_nobuf] -force
  assign_bd_address -offset 0xFF310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_psm] -force
  assign_bd_address -offset 0xFF9B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_afi_0] -force
  assign_bd_address -offset 0xFF0A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_secure_slcr_0] -force
  assign_bd_address -offset 0xFF080000 -range 0x00020000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_slcr_0] -force
  assign_bd_address -offset 0xFF410000 -range 0x00100000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_0] -force
  assign_bd_address -offset 0xFF510000 -range 0x00040000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_secure_0] -force
  assign_bd_address -offset 0xFF990000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_xppu_0] -force
  assign_bd_address -offset 0xFF960000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ctrl] -force
  assign_bd_address -offset 0xFFFC0000 -range 0x00040000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ram_0] -force
  assign_bd_address -offset 0xFF980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_xmpu_0] -force
  assign_bd_address -offset 0x0001011E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_aes] -force
  assign_bd_address -offset 0x000101160000 -range 0x00030000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_analog_0] -force
  assign_bd_address -offset 0x0001011F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0x0001012D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0x0001012D2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_1] -force
  assign_bd_address -offset 0x0001012D4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_2] -force
  assign_bd_address -offset 0x0001012D6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_3] -force
  assign_bd_address -offset 0x0001012D8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_4] -force
  assign_bd_address -offset 0x0001012DA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_5] -force
  assign_bd_address -offset 0x0001012DC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_6] -force
  assign_bd_address -offset 0x0001012DE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_7] -force
  assign_bd_address -offset 0x0001012E0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_8] -force
  assign_bd_address -offset 0x0001012E2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_9] -force
  assign_bd_address -offset 0x0001012E4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_10] -force
  assign_bd_address -offset 0x0001012E6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_11] -force
  assign_bd_address -offset 0x0001012E8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_12] -force
  assign_bd_address -offset 0x0001012EA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_13] -force
  assign_bd_address -offset 0x0001012EC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_14] -force
  assign_bd_address -offset 0x0001012EE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_bcast] -force
  assign_bd_address -offset 0x0001012B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0x0001011C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_0] -force
  assign_bd_address -offset 0x0001011D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_1] -force
  assign_bd_address -offset 0x000101250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0x000101240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0x000101110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_global_0] -force
  assign_bd_address -offset 0x000100280000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_iomodule_0] -force
  assign_bd_address -offset 0xF1060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_iou_slcr_0] -force
  assign_bd_address -offset 0x000100310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0x000101030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_qspi_0] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_qspi_ospi_flash_0] -force
  assign_bd_address -offset 0x000102000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram] -force
  assign_bd_address -offset 0x000100240000 -range 0x00020000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_data_cntlr] -force
  assign_bd_address -offset 0x000100200000 -range 0x00040000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_instr_cntlr] -force
  assign_bd_address -offset 0x000106000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0x000101200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rsa] -force
  assign_bd_address -offset 0x0001012A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0x000101210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sha] -force
  assign_bd_address -offset 0x000101220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0x000102100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0x000101270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0x0001011A0000 -range 0x00020000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tap] -force
  assign_bd_address -offset 0x000100083000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_inject_0] -force
  assign_bd_address -offset 0x000100283000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_manager_0] -force
  assign_bd_address -offset 0x000101230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_trng] -force
  assign_bd_address -offset 0x0001012F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0x000101310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0x000101300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_npi_0] -force
  assign_bd_address -offset 0xFFC90000 -range 0x0000F000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_psm_global_reg] -force
  assign_bd_address -offset 0xFFE90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_atcm_global] -force
  assign_bd_address -offset 0xFFEB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_btcm_global] -force
  assign_bd_address -offset 0xFFE00000 -range 0x00040000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_tcm_ram_global] -force
  assign_bd_address -offset 0xFF9A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_rpu_0] -force
  assign_bd_address -offset 0xFF000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_sbsauart_0] -force
  assign_bd_address -offset 0xFF130000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_scntr_0] -force
  assign_bd_address -offset 0xFF140000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_scntrs_0] -force
  assign_bd_address -offset 0xFF0E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_0] -force
  assign_bd_address -offset 0xFF0F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_1] -force
  assign_bd_address -offset 0xFF100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_2] -force
  assign_bd_address -offset 0xFF110000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_3] -force
  assign_bd_address -offset 0x000108800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_coresight_0] -force
  assign_bd_address -offset 0x000109260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_crp_0] -force
  assign_bd_address -offset 0x0001091E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_aes] -force
  assign_bd_address -offset 0x000109160000 -range 0x00030000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_analog_0] -force
  assign_bd_address -offset 0x0001091F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0x0001092D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0x0001092D2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_1] -force
  assign_bd_address -offset 0x0001092D4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_2] -force
  assign_bd_address -offset 0x0001092D6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_3] -force
  assign_bd_address -offset 0x0001092D8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_4] -force
  assign_bd_address -offset 0x0001092DA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_5] -force
  assign_bd_address -offset 0x0001092DC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_6] -force
  assign_bd_address -offset 0x0001092DE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_7] -force
  assign_bd_address -offset 0x0001092E0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_8] -force
  assign_bd_address -offset 0x0001092E2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_9] -force
  assign_bd_address -offset 0x0001092E4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_10] -force
  assign_bd_address -offset 0x0001092E6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_11] -force
  assign_bd_address -offset 0x0001092E8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_12] -force
  assign_bd_address -offset 0x0001092EA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_13] -force
  assign_bd_address -offset 0x0001092EC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_14] -force
  assign_bd_address -offset 0x0001092EE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_bcast] -force
  assign_bd_address -offset 0x0001092B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0x0001091C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_dma_0] -force
  assign_bd_address -offset 0x0001091D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_dma_1] -force
  assign_bd_address -offset 0x000109250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0x000109240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0x000109110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_global_0] -force
  assign_bd_address -offset 0x000108280000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_iomodule_0] -force
  assign_bd_address -offset 0x000108310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0x00010A000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram] -force
  assign_bd_address -offset 0x000108240000 -range 0x00020000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_data_cntlr] -force
  assign_bd_address -offset 0x000108200000 -range 0x00040000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_instr_cntlr] -force
  assign_bd_address -offset 0x00010E000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0x000109200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_rsa] -force
  assign_bd_address -offset 0x0001092A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0x000109210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_sha] -force
  assign_bd_address -offset 0x000109220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0x00010A100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0x000109270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0x0001091A0000 -range 0x00020000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tap] -force
  assign_bd_address -offset 0x000108083000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tmr_inject_0] -force
  assign_bd_address -offset 0x000108283000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tmr_manager_0] -force
  assign_bd_address -offset 0x000109230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_trng] -force
  assign_bd_address -offset 0x0001092F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0x000109310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0x000109300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xppu_npi_0] -force
  assign_bd_address -offset 0x000100800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_0] -force
  assign_bd_address -offset 0x000100D10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_cti] -force
  assign_bd_address -offset 0x000100D00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_dbg] -force
  assign_bd_address -offset 0x000100D30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_etm] -force
  assign_bd_address -offset 0x000100D20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_pmu] -force
  assign_bd_address -offset 0x000100D50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_cti] -force
  assign_bd_address -offset 0x000100D40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_dbg] -force
  assign_bd_address -offset 0x000100D70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_etm] -force
  assign_bd_address -offset 0x000100D60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_pmu] -force
  assign_bd_address -offset 0x000100CA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_cti] -force
  assign_bd_address -offset 0x000100C60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_ela] -force
  assign_bd_address -offset 0x000100C30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_etf] -force
  assign_bd_address -offset 0x000100C20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_fun] -force
  assign_bd_address -offset 0x000100F80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_atm] -force
  assign_bd_address -offset 0x000100FA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2a] -force
  assign_bd_address -offset 0x000100FD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2d] -force
  assign_bd_address -offset 0x000100F40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2a] -force
  assign_bd_address -offset 0x000100F50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2b] -force
  assign_bd_address -offset 0x000100F60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2c] -force
  assign_bd_address -offset 0x000100F70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2d] -force
  assign_bd_address -offset 0x000100F20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_fun] -force
  assign_bd_address -offset 0x000100F00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_rom] -force
  assign_bd_address -offset 0x000100B80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_atm] -force
  assign_bd_address -offset 0x000100BB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1b] -force
  assign_bd_address -offset 0x000100BC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1c] -force
  assign_bd_address -offset 0x000100BD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1d] -force
  assign_bd_address -offset 0x000100B70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_stm] -force
  assign_bd_address -offset 0x000100980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_lpd_atm] -force
  assign_bd_address -offset 0x0001009D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_lpd_cti] -force
  assign_bd_address -offset 0x0001008D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_pmc_cti] -force
  assign_bd_address -offset 0x000100A10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_r50_cti] -force
  assign_bd_address -offset 0x000100A50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_r51_cti] -force
  assign_bd_address -offset 0x000101260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crp_0] -force
  assign_bd_address -offset 0x0001011E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_aes] -force
  assign_bd_address -offset 0x000101160000 -range 0x00030000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_analog_0] -force
  assign_bd_address -offset 0x0001011F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0x0001012D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0x0001012D2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_1] -force
  assign_bd_address -offset 0x0001012D4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_2] -force
  assign_bd_address -offset 0x0001012D6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_3] -force
  assign_bd_address -offset 0x0001012D8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_4] -force
  assign_bd_address -offset 0x0001012DA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_5] -force
  assign_bd_address -offset 0x0001012DC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_6] -force
  assign_bd_address -offset 0x0001012DE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_7] -force
  assign_bd_address -offset 0x0001012E0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_8] -force
  assign_bd_address -offset 0x0001012E2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_9] -force
  assign_bd_address -offset 0x0001012E4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_10] -force
  assign_bd_address -offset 0x0001012E6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_11] -force
  assign_bd_address -offset 0x0001012E8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_12] -force
  assign_bd_address -offset 0x0001012EA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_13] -force
  assign_bd_address -offset 0x0001012EC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_14] -force
  assign_bd_address -offset 0x0001012EE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_bcast] -force
  assign_bd_address -offset 0x0001012B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0x0001011C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_0] -force
  assign_bd_address -offset 0x0001011D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_1] -force
  assign_bd_address -offset 0x000101250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0x000101240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0x000101110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_global_0] -force
  assign_bd_address -offset 0x000100280000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_iomodule_0] -force
  assign_bd_address -offset 0x000100310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0x000101030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_qspi_0] -force
  assign_bd_address -offset 0x000102000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram] -force
  assign_bd_address -offset 0x000100240000 -range 0x00020000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_data_cntlr] -force
  assign_bd_address -offset 0x000100200000 -range 0x00040000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_instr_cntlr] -force
  assign_bd_address -offset 0x000106000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0x000101200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rsa] -force
  assign_bd_address -offset 0x0001012A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0x000101210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sha] -force
  assign_bd_address -offset 0x000101220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0x000102100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0x000101270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0x0001011A0000 -range 0x00020000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tap] -force
  assign_bd_address -offset 0x000100083000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_inject_0] -force
  assign_bd_address -offset 0x000100283000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_manager_0] -force
  assign_bd_address -offset 0x000101230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_trng] -force
  assign_bd_address -offset 0x0001012F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0x000101310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0x000101300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_npi_0] -force
  assign_bd_address -offset 0x000108800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_coresight_0] -force
  assign_bd_address -offset 0x000109260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_crp_0] -force
  assign_bd_address -offset 0x0001091E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_aes] -force
  assign_bd_address -offset 0x000109160000 -range 0x00030000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_analog_0] -force
  assign_bd_address -offset 0x0001091F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0x0001092D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0x0001092D2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_1] -force
  assign_bd_address -offset 0x0001092D4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_2] -force
  assign_bd_address -offset 0x0001092D6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_3] -force
  assign_bd_address -offset 0x0001092D8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_4] -force
  assign_bd_address -offset 0x0001092DA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_5] -force
  assign_bd_address -offset 0x0001092DC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_6] -force
  assign_bd_address -offset 0x0001092DE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_7] -force
  assign_bd_address -offset 0x0001092E0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_8] -force
  assign_bd_address -offset 0x0001092E2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_9] -force
  assign_bd_address -offset 0x0001092E4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_10] -force
  assign_bd_address -offset 0x0001092E6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_11] -force
  assign_bd_address -offset 0x0001092E8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_12] -force
  assign_bd_address -offset 0x0001092EA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_13] -force
  assign_bd_address -offset 0x0001092EC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_14] -force
  assign_bd_address -offset 0x0001092EE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_bcast] -force
  assign_bd_address -offset 0x0001092B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0x0001091C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_dma_0] -force
  assign_bd_address -offset 0x0001091D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_dma_1] -force
  assign_bd_address -offset 0x000109250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0x000109240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0x000109110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_global_0] -force
  assign_bd_address -offset 0x000108280000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_iomodule_0] -force
  assign_bd_address -offset 0x000108310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0x00010A000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram] -force
  assign_bd_address -offset 0x000108240000 -range 0x00020000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_data_cntlr] -force
  assign_bd_address -offset 0x000108200000 -range 0x00040000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_instr_cntlr] -force
  assign_bd_address -offset 0x00010E000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0x000109200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_rsa] -force
  assign_bd_address -offset 0x0001092A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0x000109210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_sha] -force
  assign_bd_address -offset 0x000109220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0x00010A100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0x000109270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0x0001091A0000 -range 0x00020000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tap] -force
  assign_bd_address -offset 0x000108083000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tmr_inject_0] -force
  assign_bd_address -offset 0x000108283000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tmr_manager_0] -force
  assign_bd_address -offset 0x000109230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_trng] -force
  assign_bd_address -offset 0x0001092F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0x000109310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0x000109300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xppu_npi_0] -force
  assign_bd_address -offset 0x80000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces versal_cips_0/M_AXI_LPD] [get_bd_addr_segs m_axi_lpd/Reg] -force
  assign_bd_address -offset 0xFFA80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_0] -force
  assign_bd_address -offset 0xFFA90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_1] -force
  assign_bd_address -offset 0xFFAA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_2] -force
  assign_bd_address -offset 0xFFAB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_3] -force
  assign_bd_address -offset 0xFFAC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_4] -force
  assign_bd_address -offset 0xFFAD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_5] -force
  assign_bd_address -offset 0xFFAE0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_6] -force
  assign_bd_address -offset 0xFFAF0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_7] -force
  assign_bd_address -offset 0x000100800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_0] -force
  assign_bd_address -offset 0x000100D10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_cti] -force
  assign_bd_address -offset 0x000100D00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_dbg] -force
  assign_bd_address -offset 0x000100D30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_etm] -force
  assign_bd_address -offset 0x000100D20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_pmu] -force
  assign_bd_address -offset 0x000100D50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_cti] -force
  assign_bd_address -offset 0x000100D40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_dbg] -force
  assign_bd_address -offset 0x000100D70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_etm] -force
  assign_bd_address -offset 0x000100D60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_pmu] -force
  assign_bd_address -offset 0x000100CA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_cti] -force
  assign_bd_address -offset 0x000100C60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_ela] -force
  assign_bd_address -offset 0x000100C30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_etf] -force
  assign_bd_address -offset 0x000100C20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_fun] -force
  assign_bd_address -offset 0x000100F80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_atm] -force
  assign_bd_address -offset 0x000100FA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2a] -force
  assign_bd_address -offset 0x000100FD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2d] -force
  assign_bd_address -offset 0x000100F40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2a] -force
  assign_bd_address -offset 0x000100F50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2b] -force
  assign_bd_address -offset 0x000100F60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2c] -force
  assign_bd_address -offset 0x000100F70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2d] -force
  assign_bd_address -offset 0x000100F20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_fun] -force
  assign_bd_address -offset 0x000100F00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_rom] -force
  assign_bd_address -offset 0x000100B80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_atm] -force
  assign_bd_address -offset 0x000100BB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1b] -force
  assign_bd_address -offset 0x000100BC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1c] -force
  assign_bd_address -offset 0x000100BD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1d] -force
  assign_bd_address -offset 0x000100B70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_stm] -force
  assign_bd_address -offset 0x000100980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_lpd_atm] -force
  assign_bd_address -offset 0x0001009D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_lpd_cti] -force
  assign_bd_address -offset 0x0001008D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_pmc_cti] -force
  assign_bd_address -offset 0x000100A10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_r50_cti] -force
  assign_bd_address -offset 0x000100A50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_r51_cti] -force
  assign_bd_address -offset 0xFC000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_cpm] -force
  assign_bd_address -offset 0xFF5E0000 -range 0x00300000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crl_0] -force
  assign_bd_address -offset 0x000101260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crp_0] -force
  assign_bd_address -offset 0xFF0B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_gpio_2] -force
  assign_bd_address -offset 0xFF330000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_0] -force
  assign_bd_address -offset 0xFF340000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_1] -force
  assign_bd_address -offset 0xFF350000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_2] -force
  assign_bd_address -offset 0xFF360000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_3] -force
  assign_bd_address -offset 0xFF370000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_4] -force
  assign_bd_address -offset 0xFF380000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_5] -force
  assign_bd_address -offset 0xFF3A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_6] -force
  assign_bd_address -offset 0xFF320000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc] -force
  assign_bd_address -offset 0xFF390000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc_nobuf] -force
  assign_bd_address -offset 0xFF310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_psm] -force
  assign_bd_address -offset 0xFF9B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_afi_0] -force
  assign_bd_address -offset 0xFF0A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_secure_slcr_0] -force
  assign_bd_address -offset 0xFF080000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_slcr_0] -force
  assign_bd_address -offset 0xFF410000 -range 0x00100000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_0] -force
  assign_bd_address -offset 0xFF510000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_secure_0] -force
  assign_bd_address -offset 0xFF990000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_xppu_0] -force
  assign_bd_address -offset 0xFF960000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ctrl] -force
  assign_bd_address -offset 0xFFFC0000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ram_0] -force
  assign_bd_address -offset 0xFF980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_xmpu_0] -force
  assign_bd_address -offset 0x0001011E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_aes] -force
  assign_bd_address -offset 0x000101160000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_analog_0] -force
  assign_bd_address -offset 0x0001011F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0x0001012D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0x0001012D2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_1] -force
  assign_bd_address -offset 0x0001012D4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_2] -force
  assign_bd_address -offset 0x0001012D6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_3] -force
  assign_bd_address -offset 0x0001012D8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_4] -force
  assign_bd_address -offset 0x0001012DA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_5] -force
  assign_bd_address -offset 0x0001012DC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_6] -force
  assign_bd_address -offset 0x0001012DE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_7] -force
  assign_bd_address -offset 0x0001012E0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_8] -force
  assign_bd_address -offset 0x0001012E2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_9] -force
  assign_bd_address -offset 0x0001012E4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_10] -force
  assign_bd_address -offset 0x0001012E6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_11] -force
  assign_bd_address -offset 0x0001012E8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_12] -force
  assign_bd_address -offset 0x0001012EA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_13] -force
  assign_bd_address -offset 0x0001012EC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_14] -force
  assign_bd_address -offset 0x0001012EE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_bcast] -force
  assign_bd_address -offset 0x0001012B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0x0001011C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_0] -force
  assign_bd_address -offset 0x0001011D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_1] -force
  assign_bd_address -offset 0x000101250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0x000101240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0x000101110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_global_0] -force
  assign_bd_address -offset 0x000100280000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_iomodule_0] -force
  assign_bd_address -offset 0xF1060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_iou_slcr_0] -force
  assign_bd_address -offset 0x000100310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0x000101030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_qspi_0] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_qspi_ospi_flash_0] -force
  assign_bd_address -offset 0x000102000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram] -force
  assign_bd_address -offset 0x000100240000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_data_cntlr] -force
  assign_bd_address -offset 0x000100200000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_instr_cntlr] -force
  assign_bd_address -offset 0x000106000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0x000101200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rsa] -force
  assign_bd_address -offset 0x0001012A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0x000101210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sha] -force
  assign_bd_address -offset 0x000101220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0x000102100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0x000101270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0x0001011A0000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tap] -force
  assign_bd_address -offset 0x000100083000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_inject_0] -force
  assign_bd_address -offset 0x000100283000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_manager_0] -force
  assign_bd_address -offset 0x000101230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_trng] -force
  assign_bd_address -offset 0x0001012F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0x000101310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0x000101300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_npi_0] -force
  assign_bd_address -offset 0xFFC90000 -range 0x0000F000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_psm_global_reg] -force
  assign_bd_address -offset 0xFFE90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_atcm_global] -force
  assign_bd_address -offset 0xFFEB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_btcm_global] -force
  assign_bd_address -offset 0xFFE00000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_tcm_ram_global] -force
  assign_bd_address -offset 0xFF9A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_rpu_0] -force
  assign_bd_address -offset 0xFF000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_sbsauart_0] -force
  assign_bd_address -offset 0xFF130000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_scntr_0] -force
  assign_bd_address -offset 0xFF140000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_scntrs_0] -force
  assign_bd_address -offset 0xFF0E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_0] -force
  assign_bd_address -offset 0xFF0F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_1] -force
  assign_bd_address -offset 0xFF100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_2] -force
  assign_bd_address -offset 0xFF110000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_3] -force
  assign_bd_address -offset 0x000108800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_coresight_0] -force
  assign_bd_address -offset 0x000109260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_crp_0] -force
  assign_bd_address -offset 0x0001091E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_aes] -force
  assign_bd_address -offset 0x000109160000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_analog_0] -force
  assign_bd_address -offset 0x0001091F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0x0001092D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0x0001092D2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_1] -force
  assign_bd_address -offset 0x0001092D4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_2] -force
  assign_bd_address -offset 0x0001092D6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_3] -force
  assign_bd_address -offset 0x0001092D8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_4] -force
  assign_bd_address -offset 0x0001092DA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_5] -force
  assign_bd_address -offset 0x0001092DC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_6] -force
  assign_bd_address -offset 0x0001092DE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_7] -force
  assign_bd_address -offset 0x0001092E0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_8] -force
  assign_bd_address -offset 0x0001092E2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_9] -force
  assign_bd_address -offset 0x0001092E4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_10] -force
  assign_bd_address -offset 0x0001092E6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_11] -force
  assign_bd_address -offset 0x0001092E8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_12] -force
  assign_bd_address -offset 0x0001092EA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_13] -force
  assign_bd_address -offset 0x0001092EC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_14] -force
  assign_bd_address -offset 0x0001092EE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_bcast] -force
  assign_bd_address -offset 0x0001092B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0x0001091C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_dma_0] -force
  assign_bd_address -offset 0x0001091D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_dma_1] -force
  assign_bd_address -offset 0x000109250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0x000109240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0x000109110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_global_0] -force
  assign_bd_address -offset 0x000108280000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_iomodule_0] -force
  assign_bd_address -offset 0x000108310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0x00010A000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram] -force
  assign_bd_address -offset 0x000108240000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_data_cntlr] -force
  assign_bd_address -offset 0x000108200000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_instr_cntlr] -force
  assign_bd_address -offset 0x00010E000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0x000109200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_rsa] -force
  assign_bd_address -offset 0x0001092A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0x000109210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_sha] -force
  assign_bd_address -offset 0x000109220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0x00010A100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0x000109270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0x0001091A0000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tap] -force
  assign_bd_address -offset 0x000108083000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tmr_inject_0] -force
  assign_bd_address -offset 0x000108283000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tmr_manager_0] -force
  assign_bd_address -offset 0x000109230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_trng] -force
  assign_bd_address -offset 0x0001092F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0x000109310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0x000109300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xppu_npi_0] -force
  assign_bd_address -offset 0xFFA80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_0] -force
  assign_bd_address -offset 0xFFA90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_1] -force
  assign_bd_address -offset 0xFFAA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_2] -force
  assign_bd_address -offset 0xFFAB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_3] -force
  assign_bd_address -offset 0xFFAC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_4] -force
  assign_bd_address -offset 0xFFAD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_5] -force
  assign_bd_address -offset 0xFFAE0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_6] -force
  assign_bd_address -offset 0xFFAF0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_7] -force
  assign_bd_address -offset 0x000100800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_0] -force
  assign_bd_address -offset 0x000100D10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_cti] -force
  assign_bd_address -offset 0x000100D00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_dbg] -force
  assign_bd_address -offset 0x000100D30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_etm] -force
  assign_bd_address -offset 0x000100D20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_pmu] -force
  assign_bd_address -offset 0x000100D50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_cti] -force
  assign_bd_address -offset 0x000100D40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_dbg] -force
  assign_bd_address -offset 0x000100D70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_etm] -force
  assign_bd_address -offset 0x000100D60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_pmu] -force
  assign_bd_address -offset 0x000100CA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_cti] -force
  assign_bd_address -offset 0x000100C60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_ela] -force
  assign_bd_address -offset 0x000100C30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_etf] -force
  assign_bd_address -offset 0x000100C20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_fun] -force
  assign_bd_address -offset 0x000100F80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_atm] -force
  assign_bd_address -offset 0x000100FA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2a] -force
  assign_bd_address -offset 0x000100FD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2d] -force
  assign_bd_address -offset 0x000100F40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2a] -force
  assign_bd_address -offset 0x000100F50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2b] -force
  assign_bd_address -offset 0x000100F60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2c] -force
  assign_bd_address -offset 0x000100F70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2d] -force
  assign_bd_address -offset 0x000100F20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_fun] -force
  assign_bd_address -offset 0x000100F00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_rom] -force
  assign_bd_address -offset 0x000100B80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_atm] -force
  assign_bd_address -offset 0x000100BB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1b] -force
  assign_bd_address -offset 0x000100BC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1c] -force
  assign_bd_address -offset 0x000100BD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1d] -force
  assign_bd_address -offset 0x000100B70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_stm] -force
  assign_bd_address -offset 0x000100980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_lpd_atm] -force
  assign_bd_address -offset 0x0001009D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_lpd_cti] -force
  assign_bd_address -offset 0x0001008D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_pmc_cti] -force
  assign_bd_address -offset 0x000100A10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_r50_cti] -force
  assign_bd_address -offset 0x000100A50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_r51_cti] -force
  assign_bd_address -offset 0xFC000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_cpm] -force
  assign_bd_address -offset 0xFF5E0000 -range 0x00300000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crl_0] -force
  assign_bd_address -offset 0x000101260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crp_0] -force
  assign_bd_address -offset 0xFF0B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_gpio_2] -force
  assign_bd_address -offset 0xFF330000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_0] -force
  assign_bd_address -offset 0xFF340000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_1] -force
  assign_bd_address -offset 0xFF350000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_2] -force
  assign_bd_address -offset 0xFF360000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_3] -force
  assign_bd_address -offset 0xFF370000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_4] -force
  assign_bd_address -offset 0xFF380000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_5] -force
  assign_bd_address -offset 0xFF3A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_6] -force
  assign_bd_address -offset 0xFF320000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc] -force
  assign_bd_address -offset 0xFF390000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc_nobuf] -force
  assign_bd_address -offset 0xFF310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_psm] -force
  assign_bd_address -offset 0xFF9B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_afi_0] -force
  assign_bd_address -offset 0xFF0A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_secure_slcr_0] -force
  assign_bd_address -offset 0xFF080000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_slcr_0] -force
  assign_bd_address -offset 0xFF410000 -range 0x00100000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_0] -force
  assign_bd_address -offset 0xFF510000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_secure_0] -force
  assign_bd_address -offset 0xFF990000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_xppu_0] -force
  assign_bd_address -offset 0xFF960000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ctrl] -force
  assign_bd_address -offset 0xFFFC0000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ram_0] -force
  assign_bd_address -offset 0xFF980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_xmpu_0] -force
  assign_bd_address -offset 0x0001011E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_aes] -force
  assign_bd_address -offset 0x000101160000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_analog_0] -force
  assign_bd_address -offset 0x0001011F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0x0001012D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0x0001012D2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_1] -force
  assign_bd_address -offset 0x0001012D4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_2] -force
  assign_bd_address -offset 0x0001012D6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_3] -force
  assign_bd_address -offset 0x0001012D8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_4] -force
  assign_bd_address -offset 0x0001012DA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_5] -force
  assign_bd_address -offset 0x0001012DC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_6] -force
  assign_bd_address -offset 0x0001012DE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_7] -force
  assign_bd_address -offset 0x0001012E0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_8] -force
  assign_bd_address -offset 0x0001012E2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_9] -force
  assign_bd_address -offset 0x0001012E4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_10] -force
  assign_bd_address -offset 0x0001012E6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_11] -force
  assign_bd_address -offset 0x0001012E8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_12] -force
  assign_bd_address -offset 0x0001012EA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_13] -force
  assign_bd_address -offset 0x0001012EC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_14] -force
  assign_bd_address -offset 0x0001012EE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_bcast] -force
  assign_bd_address -offset 0x0001012B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0x0001011C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_0] -force
  assign_bd_address -offset 0x0001011D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_1] -force
  assign_bd_address -offset 0x000101250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0x000101240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0x000101110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_global_0] -force
  assign_bd_address -offset 0x000100280000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_iomodule_0] -force
  assign_bd_address -offset 0xF1060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_iou_slcr_0] -force
  assign_bd_address -offset 0x000100310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0x000101030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_qspi_0] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_qspi_ospi_flash_0] -force
  assign_bd_address -offset 0x000102000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram] -force
  assign_bd_address -offset 0x000100240000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_data_cntlr] -force
  assign_bd_address -offset 0x000100200000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_instr_cntlr] -force
  assign_bd_address -offset 0x000106000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0x000101200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rsa] -force
  assign_bd_address -offset 0x0001012A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0x000101210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sha] -force
  assign_bd_address -offset 0x000101220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0x000102100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0x000101270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0x0001011A0000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tap] -force
  assign_bd_address -offset 0x000100083000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_inject_0] -force
  assign_bd_address -offset 0x000100283000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_manager_0] -force
  assign_bd_address -offset 0x000101230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_trng] -force
  assign_bd_address -offset 0x0001012F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0x000101310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0x000101300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_npi_0] -force
  assign_bd_address -offset 0xFFC90000 -range 0x0000F000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_psm_global_reg] -force
  assign_bd_address -offset 0xFFE90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_atcm_global] -force
  assign_bd_address -offset 0xFFEB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_btcm_global] -force
  assign_bd_address -offset 0xFFE00000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_tcm_ram_global] -force
  assign_bd_address -offset 0xFF9A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_rpu_0] -force
  assign_bd_address -offset 0xFF000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_sbsauart_0] -force
  assign_bd_address -offset 0xFF130000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_scntr_0] -force
  assign_bd_address -offset 0xFF140000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_scntrs_0] -force
  assign_bd_address -offset 0xFF0E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_0] -force
  assign_bd_address -offset 0xFF0F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_1] -force
  assign_bd_address -offset 0xFF100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_2] -force
  assign_bd_address -offset 0xFF110000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_3] -force
  assign_bd_address -offset 0x000108800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_coresight_0] -force
  assign_bd_address -offset 0x000109260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_crp_0] -force
  assign_bd_address -offset 0x0001091E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_aes] -force
  assign_bd_address -offset 0x000109160000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_analog_0] -force
  assign_bd_address -offset 0x0001091F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0x0001092D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0x0001092D2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_1] -force
  assign_bd_address -offset 0x0001092D4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_2] -force
  assign_bd_address -offset 0x0001092D6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_3] -force
  assign_bd_address -offset 0x0001092D8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_4] -force
  assign_bd_address -offset 0x0001092DA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_5] -force
  assign_bd_address -offset 0x0001092DC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_6] -force
  assign_bd_address -offset 0x0001092DE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_7] -force
  assign_bd_address -offset 0x0001092E0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_8] -force
  assign_bd_address -offset 0x0001092E2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_9] -force
  assign_bd_address -offset 0x0001092E4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_10] -force
  assign_bd_address -offset 0x0001092E6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_11] -force
  assign_bd_address -offset 0x0001092E8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_12] -force
  assign_bd_address -offset 0x0001092EA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_13] -force
  assign_bd_address -offset 0x0001092EC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_14] -force
  assign_bd_address -offset 0x0001092EE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_bcast] -force
  assign_bd_address -offset 0x0001092B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0x0001091C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_dma_0] -force
  assign_bd_address -offset 0x0001091D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_dma_1] -force
  assign_bd_address -offset 0x000109250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0x000109240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0x000109110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_global_0] -force
  assign_bd_address -offset 0x000108280000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_iomodule_0] -force
  assign_bd_address -offset 0x000108310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0x00010A000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram] -force
  assign_bd_address -offset 0x000108240000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_data_cntlr] -force
  assign_bd_address -offset 0x000108200000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_instr_cntlr] -force
  assign_bd_address -offset 0x00010E000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0x000109200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_rsa] -force
  assign_bd_address -offset 0x0001092A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0x000109210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_sha] -force
  assign_bd_address -offset 0x000109220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0x00010A100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0x000109270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0x0001091A0000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tap] -force
  assign_bd_address -offset 0x000108083000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tmr_inject_0] -force
  assign_bd_address -offset 0x000108283000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tmr_manager_0] -force
  assign_bd_address -offset 0x000109230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_trng] -force
  assign_bd_address -offset 0x0001092F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0x000109310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0x000109300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xppu_npi_0] -force
  assign_bd_address -offset 0xFFA80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_0] -force
  assign_bd_address -offset 0xFFA90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_1] -force
  assign_bd_address -offset 0xFFAA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_2] -force
  assign_bd_address -offset 0xFFAB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_3] -force
  assign_bd_address -offset 0xFFAC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_4] -force
  assign_bd_address -offset 0xFFAD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_5] -force
  assign_bd_address -offset 0xFFAE0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_6] -force
  assign_bd_address -offset 0xFFAF0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_7] -force
  assign_bd_address -offset 0x000100800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_0] -force
  assign_bd_address -offset 0x000100D10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_cti] -force
  assign_bd_address -offset 0x000100D00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_dbg] -force
  assign_bd_address -offset 0x000100D30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_etm] -force
  assign_bd_address -offset 0x000100D20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_pmu] -force
  assign_bd_address -offset 0x000100D50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_cti] -force
  assign_bd_address -offset 0x000100D40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_dbg] -force
  assign_bd_address -offset 0x000100D70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_etm] -force
  assign_bd_address -offset 0x000100D60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_pmu] -force
  assign_bd_address -offset 0x000100CA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_cti] -force
  assign_bd_address -offset 0x000100C60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_ela] -force
  assign_bd_address -offset 0x000100C30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_etf] -force
  assign_bd_address -offset 0x000100C20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_fun] -force
  assign_bd_address -offset 0x000100F80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_atm] -force
  assign_bd_address -offset 0x000100FA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2a] -force
  assign_bd_address -offset 0x000100FD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2d] -force
  assign_bd_address -offset 0x000100F40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2a] -force
  assign_bd_address -offset 0x000100F50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2b] -force
  assign_bd_address -offset 0x000100F60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2c] -force
  assign_bd_address -offset 0x000100F70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2d] -force
  assign_bd_address -offset 0x000100F20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_fun] -force
  assign_bd_address -offset 0x000100F00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_rom] -force
  assign_bd_address -offset 0x000100B80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_atm] -force
  assign_bd_address -offset 0x000100BB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1b] -force
  assign_bd_address -offset 0x000100BC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1c] -force
  assign_bd_address -offset 0x000100BD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1d] -force
  assign_bd_address -offset 0x000100B70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_stm] -force
  assign_bd_address -offset 0x000100980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_lpd_atm] -force
  assign_bd_address -offset 0x0001009D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_lpd_cti] -force
  assign_bd_address -offset 0x0001008D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_pmc_cti] -force
  assign_bd_address -offset 0x000100A10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_r50_cti] -force
  assign_bd_address -offset 0x000100A50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_r51_cti] -force
  assign_bd_address -offset 0xFC000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_cpm] -force
  assign_bd_address -offset 0xFF5E0000 -range 0x00300000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crl_0] -force
  assign_bd_address -offset 0x000101260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crp_0] -force
  assign_bd_address -offset 0xFF0B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_gpio_2] -force
  assign_bd_address -offset 0xFF330000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_0] -force
  assign_bd_address -offset 0xFF340000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_1] -force
  assign_bd_address -offset 0xFF350000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_2] -force
  assign_bd_address -offset 0xFF360000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_3] -force
  assign_bd_address -offset 0xFF370000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_4] -force
  assign_bd_address -offset 0xFF380000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_5] -force
  assign_bd_address -offset 0xFF3A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_6] -force
  assign_bd_address -offset 0xFF320000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc] -force
  assign_bd_address -offset 0xFF390000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc_nobuf] -force
  assign_bd_address -offset 0xFF310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_psm] -force
  assign_bd_address -offset 0xFF9B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_afi_0] -force
  assign_bd_address -offset 0xFF0A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_secure_slcr_0] -force
  assign_bd_address -offset 0xFF080000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_slcr_0] -force
  assign_bd_address -offset 0xFF410000 -range 0x00100000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_0] -force
  assign_bd_address -offset 0xFF510000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_secure_0] -force
  assign_bd_address -offset 0xFF990000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_xppu_0] -force
  assign_bd_address -offset 0xFF960000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ctrl] -force
  assign_bd_address -offset 0xFFFC0000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ram_0] -force
  assign_bd_address -offset 0xFF980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_xmpu_0] -force
  assign_bd_address -offset 0x0001011E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_aes] -force
  assign_bd_address -offset 0x000101160000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_analog_0] -force
  assign_bd_address -offset 0x0001011F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0x0001012D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0x0001012D2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_1] -force
  assign_bd_address -offset 0x0001012D4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_2] -force
  assign_bd_address -offset 0x0001012D6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_3] -force
  assign_bd_address -offset 0x0001012D8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_4] -force
  assign_bd_address -offset 0x0001012DA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_5] -force
  assign_bd_address -offset 0x0001012DC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_6] -force
  assign_bd_address -offset 0x0001012DE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_7] -force
  assign_bd_address -offset 0x0001012E0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_8] -force
  assign_bd_address -offset 0x0001012E2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_9] -force
  assign_bd_address -offset 0x0001012E4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_10] -force
  assign_bd_address -offset 0x0001012E6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_11] -force
  assign_bd_address -offset 0x0001012E8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_12] -force
  assign_bd_address -offset 0x0001012EA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_13] -force
  assign_bd_address -offset 0x0001012EC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_14] -force
  assign_bd_address -offset 0x0001012EE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_bcast] -force
  assign_bd_address -offset 0x0001012B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0x0001011C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_0] -force
  assign_bd_address -offset 0x0001011D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_1] -force
  assign_bd_address -offset 0x000101250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0x000101240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0x000101110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_global_0] -force
  assign_bd_address -offset 0x000100280000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_iomodule_0] -force
  assign_bd_address -offset 0xF1060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_iou_slcr_0] -force
  assign_bd_address -offset 0x000100310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0x000101030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_qspi_0] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_qspi_ospi_flash_0] -force
  assign_bd_address -offset 0x000102000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram] -force
  assign_bd_address -offset 0x000100240000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_data_cntlr] -force
  assign_bd_address -offset 0x000100200000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_instr_cntlr] -force
  assign_bd_address -offset 0x000106000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0x000101200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rsa] -force
  assign_bd_address -offset 0x0001012A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0x000101210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sha] -force
  assign_bd_address -offset 0x000101220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0x000102100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0x000101270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0x0001011A0000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tap] -force
  assign_bd_address -offset 0x000100083000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_inject_0] -force
  assign_bd_address -offset 0x000100283000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_manager_0] -force
  assign_bd_address -offset 0x000101230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_trng] -force
  assign_bd_address -offset 0x0001012F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0x000101310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0x000101300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_npi_0] -force
  assign_bd_address -offset 0xFFC90000 -range 0x0000F000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_psm_global_reg] -force
  assign_bd_address -offset 0xFFE90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_atcm_global] -force
  assign_bd_address -offset 0xFFEB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_btcm_global] -force
  assign_bd_address -offset 0xFFE00000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_tcm_ram_global] -force
  assign_bd_address -offset 0xFF9A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_rpu_0] -force
  assign_bd_address -offset 0xFF000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_sbsauart_0] -force
  assign_bd_address -offset 0xFF130000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_scntr_0] -force
  assign_bd_address -offset 0xFF140000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_scntrs_0] -force
  assign_bd_address -offset 0xFF0E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_0] -force
  assign_bd_address -offset 0xFF0F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_1] -force
  assign_bd_address -offset 0xFF100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_2] -force
  assign_bd_address -offset 0xFF110000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_3] -force
  assign_bd_address -offset 0x000108800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_coresight_0] -force
  assign_bd_address -offset 0x000109260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_crp_0] -force
  assign_bd_address -offset 0x0001091E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_aes] -force
  assign_bd_address -offset 0x000109160000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_analog_0] -force
  assign_bd_address -offset 0x0001091F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0x0001092D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0x0001092D2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_1] -force
  assign_bd_address -offset 0x0001092D4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_2] -force
  assign_bd_address -offset 0x0001092D6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_3] -force
  assign_bd_address -offset 0x0001092D8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_4] -force
  assign_bd_address -offset 0x0001092DA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_5] -force
  assign_bd_address -offset 0x0001092DC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_6] -force
  assign_bd_address -offset 0x0001092DE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_7] -force
  assign_bd_address -offset 0x0001092E0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_8] -force
  assign_bd_address -offset 0x0001092E2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_9] -force
  assign_bd_address -offset 0x0001092E4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_10] -force
  assign_bd_address -offset 0x0001092E6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_11] -force
  assign_bd_address -offset 0x0001092E8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_12] -force
  assign_bd_address -offset 0x0001092EA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_13] -force
  assign_bd_address -offset 0x0001092EC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_14] -force
  assign_bd_address -offset 0x0001092EE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_bcast] -force
  assign_bd_address -offset 0x0001092B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0x0001091C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_dma_0] -force
  assign_bd_address -offset 0x0001091D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_dma_1] -force
  assign_bd_address -offset 0x000109250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0x000109240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0x000109110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_global_0] -force
  assign_bd_address -offset 0x000108280000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_iomodule_0] -force
  assign_bd_address -offset 0x000108310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0x00010A000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram] -force
  assign_bd_address -offset 0x000108240000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_data_cntlr] -force
  assign_bd_address -offset 0x000108200000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_instr_cntlr] -force
  assign_bd_address -offset 0x00010E000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0x000109200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_rsa] -force
  assign_bd_address -offset 0x0001092A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0x000109210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_sha] -force
  assign_bd_address -offset 0x000109220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0x00010A100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0x000109270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0x0001091A0000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tap] -force
  assign_bd_address -offset 0x000108083000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tmr_inject_0] -force
  assign_bd_address -offset 0x000108283000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tmr_manager_0] -force
  assign_bd_address -offset 0x000109230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_trng] -force
  assign_bd_address -offset 0x0001092F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0x000109310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0x000109300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xppu_npi_0] -force
  assign_bd_address -offset 0xFFA80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_0] -force
  assign_bd_address -offset 0xFFA90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_1] -force
  assign_bd_address -offset 0xFFAA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_2] -force
  assign_bd_address -offset 0xFFAB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_3] -force
  assign_bd_address -offset 0xFFAC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_4] -force
  assign_bd_address -offset 0xFFAD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_5] -force
  assign_bd_address -offset 0xFFAE0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_6] -force
  assign_bd_address -offset 0xFFAF0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_7] -force
  assign_bd_address -offset 0x000100800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_0] -force
  assign_bd_address -offset 0x000100D10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_cti] -force
  assign_bd_address -offset 0x000100D00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_dbg] -force
  assign_bd_address -offset 0x000100D30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_etm] -force
  assign_bd_address -offset 0x000100D20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_pmu] -force
  assign_bd_address -offset 0x000100D50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_cti] -force
  assign_bd_address -offset 0x000100D40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_dbg] -force
  assign_bd_address -offset 0x000100D70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_etm] -force
  assign_bd_address -offset 0x000100D60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_pmu] -force
  assign_bd_address -offset 0x000100CA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_cti] -force
  assign_bd_address -offset 0x000100C60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_ela] -force
  assign_bd_address -offset 0x000100C30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_etf] -force
  assign_bd_address -offset 0x000100C20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_fun] -force
  assign_bd_address -offset 0x000100F80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_atm] -force
  assign_bd_address -offset 0x000100FA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2a] -force
  assign_bd_address -offset 0x000100FD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2d] -force
  assign_bd_address -offset 0x000100F40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2a] -force
  assign_bd_address -offset 0x000100F50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2b] -force
  assign_bd_address -offset 0x000100F60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2c] -force
  assign_bd_address -offset 0x000100F70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2d] -force
  assign_bd_address -offset 0x000100F20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_fun] -force
  assign_bd_address -offset 0x000100F00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_rom] -force
  assign_bd_address -offset 0x000100B80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_atm] -force
  assign_bd_address -offset 0x000100BB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1b] -force
  assign_bd_address -offset 0x000100BC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1c] -force
  assign_bd_address -offset 0x000100BD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_cti1d] -force
  assign_bd_address -offset 0x000100B70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_stm] -force
  assign_bd_address -offset 0x000100980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_lpd_atm] -force
  assign_bd_address -offset 0x0001009D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_lpd_cti] -force
  assign_bd_address -offset 0x0001008D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_pmc_cti] -force
  assign_bd_address -offset 0x000100A10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_r50_cti] -force
  assign_bd_address -offset 0x000100A50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_coresight_r51_cti] -force
  assign_bd_address -offset 0xFC000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_cpm] -force
  assign_bd_address -offset 0xFF5E0000 -range 0x00300000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crl_0] -force
  assign_bd_address -offset 0x000101260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crp_0] -force
  assign_bd_address -offset 0xFF0B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_gpio_2] -force
  assign_bd_address -offset 0xFF330000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_0] -force
  assign_bd_address -offset 0xFF340000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_1] -force
  assign_bd_address -offset 0xFF350000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_2] -force
  assign_bd_address -offset 0xFF360000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_3] -force
  assign_bd_address -offset 0xFF370000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_4] -force
  assign_bd_address -offset 0xFF380000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_5] -force
  assign_bd_address -offset 0xFF3A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_6] -force
  assign_bd_address -offset 0xFF320000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc] -force
  assign_bd_address -offset 0xFF390000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc_nobuf] -force
  assign_bd_address -offset 0xFF310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_psm] -force
  assign_bd_address -offset 0xFF9B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_afi_0] -force
  assign_bd_address -offset 0xFF0A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_secure_slcr_0] -force
  assign_bd_address -offset 0xFF080000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_slcr_0] -force
  assign_bd_address -offset 0xFF410000 -range 0x00100000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_0] -force
  assign_bd_address -offset 0xFF510000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_secure_0] -force
  assign_bd_address -offset 0xFF990000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_xppu_0] -force
  assign_bd_address -offset 0xFF960000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ctrl] -force
  assign_bd_address -offset 0xFFFC0000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ram_0] -force
  assign_bd_address -offset 0xFF980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_xmpu_0] -force
  assign_bd_address -offset 0x0001011E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_aes] -force
  assign_bd_address -offset 0x000101160000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_analog_0] -force
  assign_bd_address -offset 0x0001011F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0x0001012D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0x0001012D2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_1] -force
  assign_bd_address -offset 0x0001012D4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_2] -force
  assign_bd_address -offset 0x0001012D6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_3] -force
  assign_bd_address -offset 0x0001012D8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_4] -force
  assign_bd_address -offset 0x0001012DA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_5] -force
  assign_bd_address -offset 0x0001012DC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_6] -force
  assign_bd_address -offset 0x0001012DE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_7] -force
  assign_bd_address -offset 0x0001012E0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_8] -force
  assign_bd_address -offset 0x0001012E2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_9] -force
  assign_bd_address -offset 0x0001012E4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_10] -force
  assign_bd_address -offset 0x0001012E6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_11] -force
  assign_bd_address -offset 0x0001012E8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_12] -force
  assign_bd_address -offset 0x0001012EA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_13] -force
  assign_bd_address -offset 0x0001012EC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_14] -force
  assign_bd_address -offset 0x0001012EE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_bcast] -force
  assign_bd_address -offset 0x0001012B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0x0001011C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_0] -force
  assign_bd_address -offset 0x0001011D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_1] -force
  assign_bd_address -offset 0x000101250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0x000101240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0x000101110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_global_0] -force
  assign_bd_address -offset 0x000100280000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_iomodule_0] -force
  assign_bd_address -offset 0xF1060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_iou_slcr_0] -force
  assign_bd_address -offset 0x000100310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0x000101030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_qspi_0] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_qspi_ospi_flash_0] -force
  assign_bd_address -offset 0x000102000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram] -force
  assign_bd_address -offset 0x000100240000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_data_cntlr] -force
  assign_bd_address -offset 0x000100200000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_instr_cntlr] -force
  assign_bd_address -offset 0x000106000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0x000101200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rsa] -force
  assign_bd_address -offset 0x0001012A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0x000101210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sha] -force
  assign_bd_address -offset 0x000101220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0x000102100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0x000101270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0x0001011A0000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tap] -force
  assign_bd_address -offset 0x000100083000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_inject_0] -force
  assign_bd_address -offset 0x000100283000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_manager_0] -force
  assign_bd_address -offset 0x000101230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_trng] -force
  assign_bd_address -offset 0x0001012F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0x000101310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0x000101300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_npi_0] -force
  assign_bd_address -offset 0xFFC90000 -range 0x0000F000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_psm_global_reg] -force
  assign_bd_address -offset 0xFFE90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_atcm_global] -force
  assign_bd_address -offset 0xFFEB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_btcm_global] -force
  assign_bd_address -offset 0xFFE00000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_tcm_ram_global] -force
  assign_bd_address -offset 0xFF9A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_rpu_0] -force
  assign_bd_address -offset 0xFF000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_sbsauart_0] -force
  assign_bd_address -offset 0xFF130000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_scntr_0] -force
  assign_bd_address -offset 0xFF140000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_scntrs_0] -force
  assign_bd_address -offset 0xFF0E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_0] -force
  assign_bd_address -offset 0xFF0F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_1] -force
  assign_bd_address -offset 0xFF100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_2] -force
  assign_bd_address -offset 0xFF110000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_3] -force
  assign_bd_address -offset 0x000108800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_coresight_0] -force
  assign_bd_address -offset 0x000109260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_crp_0] -force
  assign_bd_address -offset 0x0001091E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_aes] -force
  assign_bd_address -offset 0x000109160000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_analog_0] -force
  assign_bd_address -offset 0x0001091F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0x0001092D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0x0001092D2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_1] -force
  assign_bd_address -offset 0x0001092D4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_2] -force
  assign_bd_address -offset 0x0001092D6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_3] -force
  assign_bd_address -offset 0x0001092D8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_4] -force
  assign_bd_address -offset 0x0001092DA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_5] -force
  assign_bd_address -offset 0x0001092DC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_6] -force
  assign_bd_address -offset 0x0001092DE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_7] -force
  assign_bd_address -offset 0x0001092E0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_8] -force
  assign_bd_address -offset 0x0001092E2000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_9] -force
  assign_bd_address -offset 0x0001092E4000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_10] -force
  assign_bd_address -offset 0x0001092E6000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_11] -force
  assign_bd_address -offset 0x0001092E8000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_12] -force
  assign_bd_address -offset 0x0001092EA000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_13] -force
  assign_bd_address -offset 0x0001092EC000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_14] -force
  assign_bd_address -offset 0x0001092EE000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfi_cframe_bcast] -force
  assign_bd_address -offset 0x0001092B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0x0001091C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_dma_0] -force
  assign_bd_address -offset 0x0001091D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_dma_1] -force
  assign_bd_address -offset 0x000109250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0x000109240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0x000109110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_global_0] -force
  assign_bd_address -offset 0x000108280000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_iomodule_0] -force
  assign_bd_address -offset 0x000108310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0x00010A000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram] -force
  assign_bd_address -offset 0x000108240000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_data_cntlr] -force
  assign_bd_address -offset 0x000108200000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_instr_cntlr] -force
  assign_bd_address -offset 0x00010E000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0x000109200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_rsa] -force
  assign_bd_address -offset 0x0001092A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0x000109210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_sha] -force
  assign_bd_address -offset 0x000109220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0x00010A100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0x000109270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0x0001091A0000 -range 0x00020000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tap] -force
  assign_bd_address -offset 0x000108083000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tmr_inject_0] -force
  assign_bd_address -offset 0x000108283000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_tmr_manager_0] -force
  assign_bd_address -offset 0x000109230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_trng] -force
  assign_bd_address -offset 0x0001092F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0x000109310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0x000109300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_1/pspmc_0_slv1_psv_pmc_xppu_npi_0] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_apu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crf_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_cci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_gpv_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_maincci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slave_xmpu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_secure_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmutcu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_apu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crf_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_cci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_gpv_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_maincci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slave_xmpu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_secure_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc1] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmutcu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_apu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crf_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_cci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_gpv_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_maincci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slave_xmpu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_secure_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc2] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmutcu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_apu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crf_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_cci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_gpv_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_maincci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slave_xmpu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_secure_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces s_axi_pmc3] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmutcu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_apu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crf_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_cci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_gpv_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_maincci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slave_xmpu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_secure_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/CPM_PCIE_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmutcu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_CPM_PCIE_0/pspmc_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_3]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_4]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_5]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_6]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_adma_7]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_apu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_cpm]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crf_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_crl_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_cci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_gpv_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_maincci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slave_xmpu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_secure_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmutcu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_gpio_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_3]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_4]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_5]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_6]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc_nobuf]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ipi_psm]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_afi_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_secure_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_secure_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_lpd_xppu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ctrl]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ram_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ocm_xmpu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_iou_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_pmc_qspi_ospi_flash_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_psm_global_reg]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_atcm_global]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_btcm_global]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_r5_tcm_ram_global]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_rpu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_sbsauart_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_scntr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_scntrs_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces versal_cips_0/FPD_AXI_NOC_0] [get_bd_addr_segs versal_cips_0/NOC_PMC_AXI_0/pspmc_0_psv_ttc_3]


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


