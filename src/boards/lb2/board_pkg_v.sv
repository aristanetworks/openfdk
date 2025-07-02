//------------------------------------------------------------------------------
// Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
//------------------------------------------------------------------------------
// Maintainers:
//   fdk-support@arista.com
//
// Description:
//   Package file which describes board-specific constants.
//
//   Licensed under BSD 3-clause license:
//     https://opensource.org/licenses/BSD-3-Clause
//
// Tags:
//   noencrypt
//   license-bsd-3-clause
//
//------------------------------------------------------------------------------

package board_pkg_v;

  // Declare Package
  import hermes_pkg_v::*;
  import fpga_spec_pkg_v::*;

  //----------------------------------------------------------------------------
  // Constant and Type Definitions
  //----------------------------------------------------------------------------
  localparam BOARD_STD_C                    = "LB2";
  localparam mm_fpga_target_t FPGA_TARGET_C = MM_FPGA_XILINX_XCVU9P_33;

  localparam NUM_GT_REFCLKS_C     = 24;
  localparam NUM_GT_PORTS_C       = 68;
  localparam NUM_PCIE_LANES_C     = 8;
  localparam NUM_I2C_C            = 7;
  localparam NUM_GPIO_C           = 4;
  localparam NUM_RESERVED_IN_C    = 4;
  localparam NUM_RESERVED_OUT_C   = 1;
  localparam NUM_RESERVED_INOUT_C = 4;
  localparam NUM_DIMMS_C          = 4;
  localparam NUM_USER_REFCLKS_C   = 2;

  typedef struct {
    hermes_cfg_t   hermes_cfg;

    logic [31 : 0] bitstream_id;

    logic [2 : 0]  eeprom_sts;
    logic [15 : 0] sysmon_alm;
    logic [13 : 0] sem_status;
    } top_reserved_in_t;

  typedef struct {
    logic sem_enable;
    } top_reserved_out_t;

endpackage

