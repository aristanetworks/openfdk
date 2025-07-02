//------------------------------------------------------------------------------
// Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
//------------------------------------------------------------------------------
// Maintainers:
//   fdk-support@arista.com
//
// Description:
//   Verilog counterpart of metamako_pkg.vhd
//
// Tags:
//   noencrypt
//   license-arista-fdk-agreement
//   license-bsd-3-clause
//
//------------------------------------------------------------------------------


package arista_pkg_v;

  //----------------------------------------------------------------------------
  // Constant and Type Definitions
  //----------------------------------------------------------------------------
  localparam int len_byte = 8;

  typedef struct {
    logic [4:0] vector;
    } slv5_array_t;

  // logic differential pair
  typedef struct {
    logic p;
    logic n;
    } diffpair_t;

  typedef struct {
    diffpair_t     dqs [17 : 0];
    logic [71 : 0] dq;
    logic [8 : 0]  dm;
    } ddr4_inout_t;

  typedef struct {
    logic [17 : 0] addr;
    logic [1 : 0]  ba;
    logic [1 : 0]  bg;
    logic          reset_n;
    diffpair_t     ck       [1 : 0];
    logic [1 : 0]  cke;
    logic [3 : 0]  cs_n;
    logic [1 : 0]  odt;
    logic          act_n;
    logic          parity;
    } ddr4_host2mem_t;

  typedef struct {
    logic [7:1] data;
    } i2c_addr_t;

  typedef struct packed {
    logic [31:0] vector;
    } slv32_array_t;

  //----------------------------------------------------------------------------
  // functions Definitions
  //----------------------------------------------------------------------------

  function automatic logic [31:0] str_chunk_4bytes(input logic   [0:16*len_byte-1] input_str,
                                                   input integer                   start);
    logic [31:0]                 retval;

    // output mapping
    for (int i = 0; i < 4; i++) begin
      if(start + i < 16) begin
        retval[((i+1)*len_byte - 1)-: len_byte] = input_str[(start + i)*len_byte+: len_byte];
      end
    end

    return retval;
  endfunction

endpackage
