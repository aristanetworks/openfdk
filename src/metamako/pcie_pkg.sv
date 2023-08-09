//------------------------------------------------------------------------------
// Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
//------------------------------------------------------------------------------
// Author:
//   fdk-support@arista.com
//
// Description:
//   Verilog counterpart of pcie_pkg.vhd
//
// Tags:
//   noencrypt
//   license-arista-fdk-agreement
//   license-bsd-3-clause
//
//------------------------------------------------------------------------------


package pcie_pkg;

// Declare Package
import arista_pkg::*;

// ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Constant and Type Definitions
// ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
typedef struct{
  diffpair_t data [7 : 0];
  logic perst_n;
  diffpair_t refclk;
} pcie_8lane_root2ep_t;

typedef struct{
  diffpair_t data [7 : 0];
} pcie_8lane_ep2root_t;

endpackage


