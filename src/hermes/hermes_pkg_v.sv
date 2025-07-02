//------------------------------------------------------------------------------
// Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
//------------------------------------------------------------------------------
// Maintainers:
//   fdk-support@arista.com
//
// Description:
//   Verilog counterpart of hermes_pkg.vhd
//
// Tags:
//   noencrypt
//   license-arista-fdk-agreement
//   license-bsd-3-clause
//
//------------------------------------------------------------------------------

package hermes_pkg_v;

// ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Constant and Type Definitions
// ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
typedef struct{
  logic          vld;
  logic [47 : 0] fpga_mac;
  logic [31 : 0] fpga_ip ;
  logic [47 : 0] host_mac;
  logic [31 : 0] host_ip ;
} hermes_cfg_t;

endpackage


