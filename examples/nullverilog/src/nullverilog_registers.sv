//------------------------------------------------------------------------------
// Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
//------------------------------------------------------------------------------
// Maintainers:
//   fdk-support@arista.com
//
// Description:
//   Example register interface for the NullVerilog example design in Verilog.
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

import arista_pkg_v::*;

module null_registers_v #(
  parameter PROJECT_NAME_G)
  (
    input                reg_clk,
    input                reg_avld,
    input  [15 : 0]      reg_addr,
    output reg           reg_rvld,
    output reg [31 : 0]  reg_rdata,
    input                reg_wvld,
    input  [31 : 0 ]     reg_wdata,

    // Status
    input  [2 : 0]   fpga_id
  );

  //------------------------------------------------------------------------------
  // Signal Declarations
  //------------------------------------------------------------------------------
  reg [15 : 0]      reg_address;
  reg               reg_wvld_r;
  reg [31 : 0]      reg_wdata_r;

  slv32_array_t [8:5] scratch;

  wire [0:8*16-1] project_name_str = PROJECT_NAME_G;

  //------------------------------------------------------------------------------
  // Register Controller
  always @ (posedge reg_clk) begin
    if (reg_avld == 1'b1) begin // update local register address
      reg_address <= reg_addr;
    end;

    // Delay one cycle to match reg_address...
    reg_wvld_r  <= reg_wvld;
    reg_wdata_r <= reg_wdata;

    // Defaults...
    reg_rvld  <= 1'b1;
    reg_rdata <= 32'b0;

    if (reg_address == '0) begin
      reg_rdata <= str_chunk_4bytes(project_name_str, 0);

    end else if (reg_address == 32'd1) begin
      reg_rdata <= str_chunk_4bytes(project_name_str, 4);

    end else if (reg_address == 32'd2) begin
      reg_rdata <= str_chunk_4bytes(project_name_str, 8);

    end else if (reg_address == 32'd3) begin
      reg_rdata <= str_chunk_4bytes(project_name_str, 12);

    end else if (reg_address == 32'd4) begin
      reg_rdata[2:0] <= fpga_id;

    end else if ((reg_address >= 32'd5) && (reg_address <= 32'd8)) begin
      reg_rdata <= scratch[reg_address];
      if (reg_wvld_r == 1'b1) begin
        scratch[reg_address] <= reg_wdata_r;
      end;
    end
  end


endmodule


