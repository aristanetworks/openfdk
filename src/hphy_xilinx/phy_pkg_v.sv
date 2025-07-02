//------------------------------------------------------------------------------
// Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
//------------------------------------------------------------------------------
// Maintainers:
//   fdk-support@arista.com
//
// Description:
//   Verilog counterpart of phy_pkg.vhd
//
// Tags:
//   noencrypt
//   license-arista-fdk-agreement
//   license-bsd-3-clause
//
//------------------------------------------------------------------------------


package phy_pkg_v;

// ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Constant and Type Definitions
// ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
typedef struct{
  logic [4:0] txdiffctrl;
  logic [4:0] txprecursor;
  logic [4:0] txpostcursor;
  logic txpolarity;
  logic txinhibit;
  logic rxdfeen;
  logic rxpolarity;
  logic rxinhibit;
  logic eyescanreset;
  logic rxreset;
} gt_cfg_t;

endpackage