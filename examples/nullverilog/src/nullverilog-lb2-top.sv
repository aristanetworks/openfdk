//------------------------------------------------------------------------------
// Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
//------------------------------------------------------------------------------
// Maintainers:
//   fdk-support@arista.com
//
// Description:
//   Top level module for the NullVerilog example in Verilog running on the LB-series board
//   standards.
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
import hermes_pkg_v::*;
import pcie_pkg_v::*;
import arista_pkg_v::*;
import phy_pkg_v::*;
import fpga_spec_pkg_v::*;

module top_v #(
  parameter PROJECT_NAME_G = "lseries_null_v  ",
  parameter logic[7:1] I2C_BASE_ADDR_G = 7'b1110010
  ) (
  input                            refclk_25,
  input                            refclk_25_rst,
  input                            refclk_50,
  input                            refclk_50_rst,

  input [NUM_USER_REFCLKS_C-1 : 0] refclk_user,
  output diffpair_t                refclk_out,

  input                            pps_in_n,
  output                           pps_out,
  input                            ts_clk_in,
  input  diffpair_t                ts_diff_clk,
  output                           ts_clk_out,

  input  diffpair_t                sync_in,
  output diffpair_t                sync_out,

  input  [NUM_I2C_C-1 : 1]         i2c_scl_in,
  output [NUM_I2C_C-1 : 1]         i2c_scl_out,
  input  [NUM_I2C_C-1 : 1]         i2c_sda_in,
  output [NUM_I2C_C-1 : 1]         i2c_sda_out,
  input  [NUM_GPIO_C-1 : 0]        gpio_in,
  output [NUM_GPIO_C-1 : 0]        gpio_out,
  output [NUM_GPIO_C-1 : 0]        gpio_tri,

  input  gt_cfg_t                  gt_cfg           [NUM_GT_PORTS_C : 1],
  input  diffpair_t                gt_refclk        [NUM_GT_REFCLKS_C-1 : 0],
  output diffpair_t                gt_tx            [NUM_GT_PORTS_C : 1],
  input  diffpair_t                gt_rx            [NUM_GT_PORTS_C : 1],

  input  pcie_8lane_root2ep_t      pcie_root2ep,
  output pcie_8lane_ep2root_t      pcie_ep2root,

  input  diffpair_t                ddr4_sysclk      [NUM_DIMMS_C-1 : 0],
  inout  ddr4_inout_t              ddr4_data_strobe [NUM_DIMMS_C-1 : 0],
  output ddr4_host2mem_t           ddr4_ctrl        [NUM_DIMMS_C-1 : 0],

  input [2 : 0]                    fpga_id,
  input [15 : 0]                   platform_id,
  input [15 : 0]                   boardstd_id,
  input [15 : 0]                   mac_baseaddr,
  input [15 : 0]                   mac_total,

  input [9 : 0]                    sysmon_temp,
  output                           crc_error,

  // Signals below are reserved and subject to change
  input  top_reserved_in_t         reserved_in,
  output top_reserved_out_t        reserved_out
  );

//------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  // Constant Declarations
  //------------------------------------------------------------------------------
  mm_fpga_family_t FPGA_FAMILY_C;
  assign FPGA_FAMILY_C = mm_get_fpga_family(FPGA_TARGET_C);

  //----------------------------------------------------------------------------
  // Signal Declarations
  //----------------------------------------------------------------------------
  // Timing Reference Signals
  wire pps;
  wire pps_n;
  wire ts_clk_buf;
  wire refclk_ts;

  // Register Interface
  wire          reg_addr_vld;
  wire [15 : 0] reg_addr;
  wire          reg_rdat_vld;
  wire [31 : 0] reg_rdat;
  wire          reg_wdat_vld;
  wire [31 : 0] reg_wdat;

//------------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // Register Interfacing
  //----------------------------------------------------------------------------

  i2c_reg_protocol i2c_slave_i (
    .clk       (refclk_25),
    .rst       (refclk_25_rst),
    .base_addr (I2C_BASE_ADDR_G),

    // I2C Bus interface
    .scl_in    (i2c_scl_in[1]),
    .scl_low_n (i2c_scl_out[1]),
    .sda_in    (i2c_sda_in[1]),
    .sda_low_n (i2c_sda_out[1]),

    // Register Interface
    .reg_avld  (reg_addr_vld),
    .reg_addr  (reg_addr),
    .reg_rvld  (reg_rdat_vld),
    .reg_rdata (reg_rdat),
    .reg_wvld  (reg_wdat_vld),
    .reg_wdata (reg_wdat)
    );

  null_registers_v # (
    .PROJECT_NAME_G  (PROJECT_NAME_G)
    )
  registers_i (
    .reg_clk   (refclk_25),
    .reg_avld  (reg_addr_vld),
    .reg_addr  (reg_addr),
    .reg_rvld  (reg_rdat_vld),
    .reg_rdata (reg_rdat),
    .reg_wvld  (reg_wdat_vld),
    .reg_wdata (reg_wdat),

    .fpga_id   (fpga_id)
    );

  //----------------------------------------------------------------------------
  // Timing References
  //
  IBUF ibuf_pps (
    .I(pps_in_n),
    .O(pps_n)
    );

  assign pps = ~ pps_n;

  OBUF obuf_pps (
    .I(pps),
    .O(pps_out)
    );

  IBUF ibuf_ts_clk(
    .I(ts_clk_in),
    .O(ts_clk_buf)
    );

  BUFG bufg_ts_clk(
    .I(ts_clk_buf),
    .O(refclk_ts)
    );

  OBUF obuf_ts_clk(
    .I(refclk_ts),
    .O(ts_clk_out)
    );

  OBUFDS obufds_refclk(
    .I (1'b0),
    .O (refclk_out.p),
    .OB(refclk_out.n)
    );

  OBUFDS obufds_sync(
    .I (1'b0),
    .O (sync_out.p),
    .OB(sync_out.n)
    );

  //----------------------------------------------------------------------------
  // Unused Tieoffs Signals
  //----------------------------------------------------------------------------

  genvar i, j;
  generate
    for (i = 0; i < NUM_DIMMS_C; i=i+1) begin
      assign ddr4_data_strobe[i].dq = 'z;
      assign ddr4_data_strobe[i].dm = 'z;

      assign ddr4_ctrl[i].addr    = '0;
      assign ddr4_ctrl[i].ba      = '0;
      assign ddr4_ctrl[i].bg      = '0;
      assign ddr4_ctrl[i].reset_n = 1'b1;
      assign ddr4_ctrl[i].cke     = '0;
      assign ddr4_ctrl[i].cs_n    = '1;
      assign ddr4_ctrl[i].odt     = '0;
      assign ddr4_ctrl[i].act_n   = 1'b1;
      assign ddr4_ctrl[i].parity  = 1'b0;

      for (j = 0; j < $size(ddr4_ctrl[i].ck); j=j+1) begin
        OBUFDS obufds_ddr4_ck (
          .I  (1'b0),
          .O  (ddr4_ctrl[i].ck[j].p),
          .OB (ddr4_ctrl[i].ck[j].n)
          );
      end

      for (j = 0; j < $size(ddr4_data_strobe[i].dqs); j=j+1) begin
        wire IO_in;
        wire IOB_in;

        // Map inout ports to buffers
        assign IO_in  = ddr4_data_strobe[i].dqs[j].p;
        assign IOB_in = ddr4_data_strobe[i].dqs[j].n;

        IOBUFDS iobufds_ddr4_dqs (
          .IO  (IO_in),
          .IOB (IOB_in),
          .I   (1'b0),
          .O   (),
          .T   (1'b1)
        );
      end

      IBUFDS ibufds_ddr4_sysclk(
        .I  (ddr4_sysclk[i].p),
        .IB (ddr4_sysclk[i].n),
        .O  ()
        );
    end
  endgenerate;

endmodule