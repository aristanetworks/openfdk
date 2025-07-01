//------------------------------------------------------------------------------
// Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
//------------------------------------------------------------------------------
// Maintainers:
//   fdk-support@arista.com
//
// Description:
//   This is the board level top Verilog
//   Please refer to the development kit documentation for device specific
//   interface definitions.
//
//   Licensed under BSD 3-clause license:
//     https://opensource.org/licenses/BSD-3-Clause
//
// Tags:
//   noencrypt
//   license-bsd-3-clause
//
//------------------------------------------------------------------------------

`timescale 1ps/1ps

import board_pkg_v::*;
import arista_pkg_v::*;
import pcie_pkg_v::*;
import phy_pkg_v::*;
import hermes_pkg_v::*;

module board_top (
  // Transceiver Reference Clocks
  input  [NUM_GT_REFCLKS_C-1:0] gt_refclk_p,
  input  [NUM_GT_REFCLKS_C-1:0] gt_refclk_n,

  // Transceivers
  output [NUM_GT_PORTS_C:1]     gt_tx_p,
  output [NUM_GT_PORTS_C:1]     gt_tx_n,
  input  [NUM_GT_PORTS_C:1]     gt_rx_p,
  input  [NUM_GT_PORTS_C:1]     gt_rx_n,

  // Reference Clock Inputs/Outputs
  input  ts_clk_in,
  output ts_clk_out,
  output ts_clk_clksel_n,
  input  ts_diff_clk_p,
  input  ts_diff_clk_n,

  // PPS Input/Output
  input  pps_in_n, // Falling Edge Active PPS pulse
  output pps_out,

  // Sync Network Inputs/Outputs
  input  sync_in_p,
  input  sync_in_n,
  output sync_out_p,
  output sync_out_n,

  // User Clocks (From Clock Generator)
  input [NUM_USER_REFCLKS_C-1 : 0] refclk_user_p,
  input [NUM_USER_REFCLKS_C-1 : 0] refclk_user_n,

  // Reference Output (To Clock Generator)
  output refclk_out_p,
  output refclk_out_n,

  // PCIe interface
  input  [NUM_PCIE_LANES_C-1:0] pcie_rx_p,
  input  [NUM_PCIE_LANES_C-1:0] pcie_rx_n,
  output [NUM_PCIE_LANES_C-1:0] pcie_tx_p,
  output [NUM_PCIE_LANES_C-1:0] pcie_tx_n,

  output pcie_wake_n,
  input  pcie_refclk_p,
  input  pcie_refclk_n,
  input  pcie_perst_n,

  // I2C interface
  inout [NUM_I2C_C-1:0] i2c_scl,
  inout [NUM_I2C_C-1:0] i2c_sda,

  // GPIO Interface
  inout [NUM_GPIO_C-1:0] gpio,

  // FPGA ID
  input [2:0] fpga_id,

  // DRAM
  input         dimm0_sys_clk_p,
  input         dimm0_sys_clk_n,
  output [17:0] dimm0_ddr4_adr,
  output [1:0]  dimm0_ddr4_ba,
  output [1:0]  dimm0_ddr4_cke,
  output [1:0]  dimm0_ddr4_cs_n,
  inout  [8:0]  dimm0_ddr4_dm_dbi_n,
  inout  [71:0] dimm0_ddr4_dq,
  inout  [8:0]  dimm0_ddr4_dqs_c,
  inout  [8:0]  dimm0_ddr4_dqs_t,
  output [1:0]  dimm0_ddr4_odt,
  output        dimm0_ddr4_parity,
  output [1:0]  dimm0_ddr4_bg,
  output        dimm0_ddr4_reset_n,
  output        dimm0_ddr4_act_n,
  output [1:0]  dimm0_ddr4_ck_c,
  output [1:0]  dimm0_ddr4_ck_t,

  input         dimm1_sys_clk_p,
  input         dimm1_sys_clk_n,
  output [17:0] dimm1_ddr4_adr,
  output [1:0]  dimm1_ddr4_ba,
  output [1:0]  dimm1_ddr4_cke,
  output [1:0]  dimm1_ddr4_cs_n,
  inout  [8:0]  dimm1_ddr4_dm_dbi_n,
  inout  [71:0] dimm1_ddr4_dq,
  inout  [8:0]  dimm1_ddr4_dqs_c,
  inout  [8:0]  dimm1_ddr4_dqs_t,
  output [1:0]  dimm1_ddr4_odt,
  output        dimm1_ddr4_parity,
  output [1:0]  dimm1_ddr4_bg,
  output        dimm1_ddr4_reset_n,
  output        dimm1_ddr4_act_n,
  output [1:0]  dimm1_ddr4_ck_c,
  output [1:0]  dimm1_ddr4_ck_t,

  input         dimm2_sys_clk_p,
  input         dimm2_sys_clk_n,
  output [17:0] dimm2_ddr4_adr,
  output [1:0]  dimm2_ddr4_ba,
  output [1:0]  dimm2_ddr4_cke,
  output [1:0]  dimm2_ddr4_cs_n,
  inout  [8:0]  dimm2_ddr4_dm_dbi_n,
  inout  [71:0] dimm2_ddr4_dq,
  inout  [8:0]  dimm2_ddr4_dqs_c,
  inout  [8:0]  dimm2_ddr4_dqs_t,
  output [1:0]  dimm2_ddr4_odt,
  output        dimm2_ddr4_parity,
  output [1:0]  dimm2_ddr4_bg,
  output        dimm2_ddr4_reset_n,
  output        dimm2_ddr4_act_n,
  output [1:0]  dimm2_ddr4_ck_c,
  output [1:0]  dimm2_ddr4_ck_t,

  input         dimm3_sys_clk_p,
  input         dimm3_sys_clk_n,
  output [17:0] dimm3_ddr4_adr,
  output [1:0]  dimm3_ddr4_ba,
  output [1:0]  dimm3_ddr4_cke,
  output [1:0]  dimm3_ddr4_cs_n,
  inout  [8:0]  dimm3_ddr4_dm_dbi_n,
  inout  [71:0] dimm3_ddr4_dq,
  inout  [8:0]  dimm3_ddr4_dqs_c,
  inout  [8:0]  dimm3_ddr4_dqs_t,
  output [1:0]  dimm3_ddr4_odt,
  output        dimm3_ddr4_parity,
  output [1:0]  dimm3_ddr4_bg,
  output        dimm3_ddr4_reset_n,
  output        dimm3_ddr4_act_n,
  output [1:0]  dimm3_ddr4_ck_c,
  output [1:0]  dimm3_ddr4_ck_t,

  // SEU Error Notification to System Controller
  output crc_error,

  // OCXO DAC
  output dac_spi_sclk,
  output dac_spi_mosi,
  output dac_cs_n,

  // System Monitor
  input vp,
  input vn,

  // Reserved IO
  input  [NUM_RESERVED_IN_C-1:0]    reserved_in,
  output [NUM_RESERVED_OUT_C-1:0]   reserved_out,
  inout  [NUM_RESERVED_INOUT_C-1:0] reserved_inout
  );

//------------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // Local Constants
  //----------------------------------------------------------------------------
  genvar i;

  localparam EN_SYSCTL_REGS_C = 1'b1;
  localparam EN_SYSCTL_SEM_C  = 1'b1;
  localparam EN_TEMP_REG_C    = 1'b1;
  localparam EN_TEST_LOGIC_C  = 1'b0;
  localparam EN_TEST_GPIO_C   = 1'b0;

  //----------------------------------------------------------------------------
  // Signal Declarations
  //----------------------------------------------------------------------------
  wire [NUM_USER_REFCLKS_C-1 : 0] refclk_user_buf;
  wire [NUM_USER_REFCLKS_C-1 : 0] refclk_user    ;
  wire diffpair_t                 refclk_out;

  wire diffpair_t                 sync_in;
  wire diffpair_t                 sync_out;
  wire diffpair_t                 ts_diff_clk;

  wire                            refclk_25;
  wire                            refclk_25_rst;
  wire                            refclk_50;
  wire                            refclk_50_rst;

  wire gt_cfg_t                   gt_cfg            [NUM_GT_PORTS_C : 1];

  wire [NUM_GT_PORTS_C*5 + 4: 5]  gt_cfg_txdiffctrl;
  wire [NUM_GT_PORTS_C*5 + 4: 5]  gt_cfg_txprecursor;
  wire [NUM_GT_PORTS_C*5 + 4: 5]  gt_cfg_txpostcursor;
  wire [NUM_GT_PORTS_C : 1]       gt_cfg_txpolarity;
  wire [NUM_GT_PORTS_C : 1]       gt_cfg_txinhibit;
  wire [NUM_GT_PORTS_C : 1]       gt_cfg_rxdfeen;
  wire [NUM_GT_PORTS_C : 1]       gt_cfg_rxpolarity;
  wire [NUM_GT_PORTS_C : 1]       gt_cfg_eyescanreset;
  wire [NUM_GT_PORTS_C : 1]       gt_cfg_rxreset;

  wire diffpair_t                 gt_refclk        [NUM_GT_REFCLKS_C-1 : 0];
  wire diffpair_t                 gt_rx            [NUM_GT_PORTS_C : 1];
  wire diffpair_t                 gt_tx            [NUM_GT_PORTS_C : 1];

  wire pcie_8lane_root2ep_t       pcie_root2ep;
  wire pcie_8lane_ep2root_t       pcie_ep2root;

  wire ddr4_inout_t               ddr4_data_strobe [NUM_DIMMS_C-1 : 0];
  wire ddr4_host2mem_t            ddr4_ctrl        [NUM_DIMMS_C-1 : 0];
  wire diffpair_t                 ddr4_sysclk      [NUM_DIMMS_C-1 : 0];

  wire [NUM_I2C_C-1 : 1 ]         i2c_scl_in;
  wire [NUM_I2C_C-1 : 1 ]         i2c_scl_out;
  wire [NUM_I2C_C-1 : 1 ]         i2c_sda_in;
  wire [NUM_I2C_C-1 : 1 ]         i2c_sda_out;
  wire [NUM_GPIO_C-1 : 0]         gpio_in;
  wire [NUM_GPIO_C-1 : 0]         gpio_out;
  wire [NUM_GPIO_C-1 : 0]         gpio_tri;

  wire                            sem_clock;
  wire                            usr_crc_error;
  wire                            sem_error;

  wire [2:0]                      fpga_id_i;
  wire [15:0]                     sysmon_alm;
  wire [15:0]                     platform_id;
  wire [15:0]                     boardstd_id;
  wire [47:0]                     mac_baseaddr;
  wire [7:0]                      mac_total;
  wire [9:0]                      sysmon_temp;

  wire top_reserved_in_t          top_reserved_in;
  wire top_reserved_out_t         top_reserved_out;

  //------------------------------------------------------------------------------

  top_v proj_top_i (
    .refclk_25        (refclk_25),
    .refclk_25_rst    (refclk_25_rst),
    .refclk_50        (refclk_50),
    .refclk_50_rst    (refclk_50_rst),

    .refclk_user      (refclk_user),
    .refclk_out       (refclk_out),

    .pps_in_n         (pps_in_n),
    .pps_out          (pps_out),
    .ts_clk_in        (ts_clk_in),
    .ts_diff_clk      (ts_diff_clk),
    .ts_clk_out       (ts_clk_out),

    .sync_in          (sync_in),
    .sync_out         (sync_out),

    .i2c_scl_in       (i2c_scl_in),
    .i2c_scl_out      (i2c_scl_out),
    .i2c_sda_in       (i2c_sda_in),
    .i2c_sda_out      (i2c_sda_out),
    .gpio_in          (gpio_in),
    .gpio_out         (gpio_out),
    .gpio_tri         (gpio_tri),

    .gt_cfg           (gt_cfg),
    .gt_refclk        (gt_refclk),
    .gt_tx            (gt_tx),
    .gt_rx            (gt_rx),

    .pcie_root2ep     (pcie_root2ep),
    .pcie_ep2root     (pcie_ep2root),

    .ddr4_sysclk      (ddr4_sysclk),
    .ddr4_data_strobe (ddr4_data_strobe),
    .ddr4_ctrl        (ddr4_ctrl),

    .fpga_id          (fpga_id_i),
    .platform_id      (platform_id),
    .boardstd_id      (boardstd_id),
    .mac_baseaddr     (mac_baseaddr),
    .mac_total        (mac_total),

    .sysmon_temp      (sysmon_temp),
    .crc_error        (usr_crc_error),

    .reserved_in      (top_reserved_in),
    .reserved_out     (top_reserved_out)
    );

  assign crc_error = usr_crc_error | sem_error;

  // ------------------------------------------------------------------------------
  // -- Concurrent Assignments
  // ------------------------------------------------------------------------------
  // refclk_user
  generate
    for(i = 0; i < NUM_USER_REFCLKS_C; i=i+1) begin
      IBUFDS ibufds_refclk_user (
        .I (refclk_user_p[i]),
        .IB(refclk_user_n[i]),
        .O (refclk_user_buf[i])
        );

      BUFG bufg_refclk_user (
        .I(refclk_user_buf[i]),
        .O(refclk_user[i])
        );
    end
  endgenerate

  // Note : this clock very specifically, does NOT go through a PLL to
  // minimise configurable logic between pin and SEM.
  BUFGCE_DIV #(
    .BUFGCE_DIVIDE(2))
  bufg_sem_clock (
    .CE  (1'b1),
    .CLR (1'b0),
    .I   (refclk_user_buf[0]),
    .O   (sem_clock)
    );

  // refclk_out
  assign refclk_out_p  = refclk_out.p;
  assign refclk_out_n  = refclk_out.n;

  // ts_diff_clk
  assign ts_diff_clk.p = ts_diff_clk_p;
  assign ts_diff_clk.n = ts_diff_clk_n;

  // Sync
  assign sync_in.p     = sync_in_p;
  assign sync_in.n     = sync_in_n;
  assign sync_out_p    = sync_out.p;
  assign sync_out_n    = sync_out.n;

  // GT Transceivers
  generate
    for(i = 0; i < NUM_GT_REFCLKS_C; i=i+1) begin
      assign gt_refclk[i].p = gt_refclk_p[i];
      assign gt_refclk[i].n = gt_refclk_n[i];
    end
  endgenerate

  generate
    for(i = 1; i < NUM_GT_PORTS_C + 1; i=i+1) begin
      assign gt_rx[i].p = gt_rx_p[i];
      assign gt_rx[i].n = gt_rx_n[i];
      assign gt_tx_p[i] = gt_tx[i].p;
      assign gt_tx_n[i] = gt_tx[i].n;
    end
  endgenerate

  // PCIe
  generate
    for(i = 0; i < NUM_PCIE_LANES_C; i=i+1) begin
      assign pcie_root2ep.data[i].p = pcie_rx_p[i];
      assign pcie_root2ep.data[i].n = pcie_rx_n[i];
      assign pcie_tx_p[i]           = pcie_ep2root.data[i].p;
      assign pcie_tx_n[i]           = pcie_ep2root.data[i].n;
    end
  endgenerate

  assign pcie_root2ep.perst_n  = pcie_perst_n;
  assign pcie_root2ep.refclk.p = pcie_refclk_p;
  assign pcie_root2ep.refclk.n = pcie_refclk_n;
  assign pcie_wake_n           = 1'bZ;

  // Map DDR4 signals to records
  // dimm0
  assign ddr4_sysclk[0].p    = dimm0_sys_clk_p;
  assign ddr4_sysclk[0].n    = dimm0_sys_clk_n;
  assign dimm0_ddr4_adr      = ddr4_ctrl[0].addr;
  assign dimm0_ddr4_ba       = ddr4_ctrl[0].ba;
  assign dimm0_ddr4_bg       = ddr4_ctrl[0].bg;
  assign dimm0_ddr4_ck_c[0]  = ddr4_ctrl[0].ck[0].n;
  assign dimm0_ddr4_ck_t[0]  = ddr4_ctrl[0].ck[0].p;
  assign dimm0_ddr4_ck_c[1]  = ddr4_ctrl[0].ck[1].n;
  assign dimm0_ddr4_ck_t[1]  = ddr4_ctrl[0].ck[1].p;
  assign dimm0_ddr4_cke      = ddr4_ctrl[0].cke;
  assign dimm0_ddr4_parity   = ddr4_ctrl[0].parity;
  assign dimm0_ddr4_act_n    = ddr4_ctrl[0].act_n;
  assign dimm0_ddr4_reset_n  = ddr4_ctrl[0].reset_n;
  assign dimm0_ddr4_cs_n     = ddr4_ctrl[0].cs_n[1 : 0];
  assign dimm0_ddr4_odt      = ddr4_ctrl[0].odt;
  assign dimm0_ddr4_dm_dbi_n = ddr4_data_strobe[0].dm;
  assign dimm0_ddr4_dq       = ddr4_data_strobe[0].dq;
  generate
    for(i = 0; i < 9; i=i+1) begin
      assign dimm0_ddr4_dqs_c[i] = ddr4_data_strobe[0].dqs[i].n;
      assign dimm0_ddr4_dqs_t[i] = ddr4_data_strobe[0].dqs[i].p;
    end
  endgenerate

  // dimm1
  assign ddr4_sysclk[1].p    = dimm1_sys_clk_p;
  assign ddr4_sysclk[1].n    = dimm1_sys_clk_n;
  assign dimm1_ddr4_adr      = ddr4_ctrl[1].addr;
  assign dimm1_ddr4_ba       = ddr4_ctrl[1].ba;
  assign dimm1_ddr4_bg       = ddr4_ctrl[1].bg;
  assign dimm1_ddr4_ck_c[0]  = ddr4_ctrl[1].ck[0].n;
  assign dimm1_ddr4_ck_t[0]  = ddr4_ctrl[1].ck[0].p;
  assign dimm1_ddr4_ck_c[1]  = ddr4_ctrl[1].ck[1].n;
  assign dimm1_ddr4_ck_t[1]  = ddr4_ctrl[1].ck[1].p;
  assign dimm1_ddr4_cke      = ddr4_ctrl[1].cke;
  assign dimm1_ddr4_parity   = ddr4_ctrl[1].parity;
  assign dimm1_ddr4_act_n    = ddr4_ctrl[1].act_n;
  assign dimm1_ddr4_reset_n  = ddr4_ctrl[1].reset_n;
  assign dimm1_ddr4_cs_n     = ddr4_ctrl[1].cs_n[1 : 0];
  assign dimm1_ddr4_odt      = ddr4_ctrl[1].odt;
  assign dimm1_ddr4_dm_dbi_n = ddr4_data_strobe[1].dm;
  assign dimm1_ddr4_dq       = ddr4_data_strobe[1].dq;
  generate
    for(i = 0; i < 9; i=i+1) begin
      assign dimm1_ddr4_dqs_c[i] = ddr4_data_strobe[1].dqs[i].n;
      assign dimm1_ddr4_dqs_t[i] = ddr4_data_strobe[1].dqs[i].p;
    end
  endgenerate

  // dimm2
  assign ddr4_sysclk[2].p    = dimm2_sys_clk_p;
  assign ddr4_sysclk[2].n    = dimm2_sys_clk_n;
  assign dimm2_ddr4_adr      = ddr4_ctrl[2].addr;
  assign dimm2_ddr4_ba       = ddr4_ctrl[2].ba;
  assign dimm2_ddr4_bg       = ddr4_ctrl[2].bg;
  assign dimm2_ddr4_ck_c[0]  = ddr4_ctrl[2].ck[0].n;
  assign dimm2_ddr4_ck_t[0]  = ddr4_ctrl[2].ck[0].p;
  assign dimm2_ddr4_ck_c[1]  = ddr4_ctrl[2].ck[1].n;
  assign dimm2_ddr4_ck_t[1]  = ddr4_ctrl[2].ck[1].p;
  assign dimm2_ddr4_cke      = ddr4_ctrl[2].cke;
  assign dimm2_ddr4_parity   = ddr4_ctrl[2].parity;
  assign dimm2_ddr4_act_n    = ddr4_ctrl[2].act_n;
  assign dimm2_ddr4_reset_n  = ddr4_ctrl[2].reset_n;
  assign dimm2_ddr4_cs_n     = ddr4_ctrl[2].cs_n[1 : 0];
  assign dimm2_ddr4_odt      = ddr4_ctrl[2].odt;
  assign dimm2_ddr4_dm_dbi_n = ddr4_data_strobe[2].dm;
  assign dimm2_ddr4_dq       = ddr4_data_strobe[2].dq;
  generate
    for(i = 0; i < 9; i=i+1) begin
      assign dimm2_ddr4_dqs_c[i] = ddr4_data_strobe[2].dqs[i].n;
      assign dimm2_ddr4_dqs_t[i] = ddr4_data_strobe[2].dqs[i].p;
    end
  endgenerate

  // dimm3
  assign ddr4_sysclk[3].p    = dimm3_sys_clk_p;
  assign ddr4_sysclk[3].n    = dimm3_sys_clk_n;
  assign dimm3_ddr4_adr      = ddr4_ctrl[3].addr;
  assign dimm3_ddr4_ba       = ddr4_ctrl[3].ba;
  assign dimm3_ddr4_bg       = ddr4_ctrl[3].bg;
  assign dimm3_ddr4_ck_c[0]  = ddr4_ctrl[3].ck[0].n;
  assign dimm3_ddr4_ck_t[0]  = ddr4_ctrl[3].ck[0].p;
  assign dimm3_ddr4_ck_c[1]  = ddr4_ctrl[3].ck[1].n;
  assign dimm3_ddr4_ck_t[1]  = ddr4_ctrl[3].ck[1].p;
  assign dimm3_ddr4_cke      = ddr4_ctrl[3].cke;
  assign dimm3_ddr4_parity   = ddr4_ctrl[3].parity;
  assign dimm3_ddr4_act_n    = ddr4_ctrl[3].act_n;
  assign dimm3_ddr4_reset_n  = ddr4_ctrl[3].reset_n;
  assign dimm3_ddr4_cs_n     = ddr4_ctrl[3].cs_n[1 : 0];
  assign dimm3_ddr4_odt      = ddr4_ctrl[3].odt;
  assign dimm3_ddr4_dm_dbi_n = ddr4_data_strobe[3].dm;
  assign dimm3_ddr4_dq       = ddr4_data_strobe[3].dq;
  generate
      for(i = 0; i < 9; i=i+1) begin
          assign dimm3_ddr4_dqs_c[i] = ddr4_data_strobe[3].dqs[i].n;
          assign dimm3_ddr4_dqs_t[i] = ddr4_data_strobe[3].dqs[i].p;
      end
  endgenerate

  // gt_cfg
  generate
    for(i = 1; i < NUM_GT_PORTS_C + 1; i=i+1) begin
      assign gt_cfg[i].txdiffctrl       = gt_cfg_txdiffctrl   [i*5+4 : i*5];
      assign gt_cfg[i].txprecursor      = gt_cfg_txprecursor  [i*5+4 : i*5];
      assign gt_cfg[i].txpostcursor     = gt_cfg_txpostcursor [i*5+4 : i*5];
      assign gt_cfg[i].txpolarity       = gt_cfg_txpolarity   [i];
      assign gt_cfg[i].txinhibit        = gt_cfg_txinhibit    [i];
      assign gt_cfg[i].rxdfeen          = gt_cfg_rxdfeen      [i];
      assign gt_cfg[i].rxpolarity       = gt_cfg_rxpolarity   [i];
      assign gt_cfg[i].eyescanreset     = gt_cfg_eyescanreset [i];
      assign gt_cfg[i].rxreset          = gt_cfg_rxreset      [i];
    end
  endgenerate

  arista_sysctl_v2_wrapper #(
    .ENABLE_SYSMON_G (1'b1),
    .ENABLE_TEMP_G   (EN_TEMP_REG_C),
    .ENABLE_EEPROM_G (1'b1),
    .ENABLE_SEM_G    (EN_SYSCTL_SEM_C),
    .ENABLE_PHYCFG_G (EN_SYSCTL_REGS_C)
    )
  arista_sysctl_i (
    .o_ygam_instance       (),

    .refclk_user           (refclk_user),
    .sem_clock             (sem_clock),

    .i2c_scl               (i2c_scl),
    .i2c_sda               (i2c_sda),

    .gpio                  (gpio),
    .fpgaid                (fpga_id),

    .dac_spi_sclk          (dac_spi_sclk),
    .dac_spi_mosi          (dac_spi_mosi),
    .dac_cs_n              (dac_cs_n),
    .ts_clk_clksel_n       (ts_clk_clksel_n),

    .vp                    (vp),
    .vn                    (vn),

    .reserved_in           (),
    .reserved_out          (),
    .reserved_inout        (),

    .refclk_25             (refclk_25),
    .refclk_25_rst         (refclk_25_rst),
    .refclk_50             (refclk_50),
    .refclk_50_rst         (refclk_50_rst),

    .gt_cfg_txdiffctrl     (gt_cfg_txdiffctrl),
    .gt_cfg_txprecursor    (gt_cfg_txprecursor),
    .gt_cfg_txpostcursor   (gt_cfg_txpostcursor),
    .gt_cfg_txpolarity     (gt_cfg_txpolarity),
    .gt_cfg_txinhibit      (gt_cfg_txinhibit),
    .gt_cfg_rxdfeen        (gt_cfg_rxdfeen),
    .gt_cfg_rxpolarity     (gt_cfg_rxpolarity),
    .gt_cfg_eyescanreset   (gt_cfg_eyescanreset),
    .gt_cfg_rxreset        (gt_cfg_rxreset),

    .hermes_cfg_vld        (top_reserved_in.hermes_cfg.vld),
    .hermes_cfg_fpga_mac   (top_reserved_in.hermes_cfg.fpga_mac),
    .hermes_cfg_fpga_ip    (top_reserved_in.hermes_cfg.fpga_ip),
    .hermes_cfg_host_mac   (top_reserved_in.hermes_cfg.host_mac),
    .hermes_cfg_host_ip    (top_reserved_in.hermes_cfg.host_ip),

    .mac_baseaddr          (mac_baseaddr),
    .mac_total             (mac_total),
    .bitstream_id          (top_reserved_in.bitstream_id),
    .platform_id           (platform_id),
    .boardstd_id           (boardstd_id),
    .fpga_id               (fpga_id_i),

    .i2c_scl_in            (i2c_scl_in),
    .i2c_scl_out           (i2c_scl_out),
    .i2c_sda_in            (i2c_sda_in),
    .i2c_sda_out           (i2c_sda_out),

    .gpio_in               (gpio_in),
    .gpio_out              (gpio_out),
    .gpio_tri              (gpio_tri),

    .eeprom_sts            (top_reserved_in.eeprom_sts),
    .sysmon_temp           (sysmon_temp),
    .sysmon_alm            (top_reserved_in.sysmon_alm),
    .sem_enable            (top_reserved_out.sem_enable),
    .sem_error             (sem_error),
    .sem_status            (top_reserved_in.sem_status)
    );

endmodule