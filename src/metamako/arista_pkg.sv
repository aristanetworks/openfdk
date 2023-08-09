//------------------------------------------------------------------------------
// Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
//------------------------------------------------------------------------------
// Author:
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


package arista_pkg;

// ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Constant and Type Definitions
// ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
typedef struct{
  logic [4:0] vector;
} slv5_array_t;

// logic differential pair
typedef struct {
  logic p;
  logic n;
} diffpair_t;

typedef struct{
  diffpair_t     dqs [17 : 0];
  logic [71 : 0] dq;
  logic [8 : 0]  dm;
} ddr4_inout_t;

typedef struct{
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

typedef struct{
  logic [7:1] data;
} i2c_addr_t;

endpackage
