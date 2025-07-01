//------------------------------------------------------------------------------
// Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
//------------------------------------------------------------------------------
// Maintainers:
//   fdk-support@arista.com
//
// Description:
//   Verilog package for FPGA models and specifications
//
// Tags:
//   noencrypt
//   license-arista-fdk-agreement
//   license-bsd-3-clause
//
//------------------------------------------------------------------------------

package fpga_spec_pkg_v;

  //----------------------------------------------------------------------------
  // Types
  //----------------------------------------------------------------------------

  // Cls : Class (FPGA, CPLD, etc)
  // Mfg : Manufacture
  // Dev : Device Name
  // Spd : Speed Grade (where 32(L) = XCVR Speed 3; Fabric Speed 2; Other Info (LowVoltage, etc))
  //                  Cls  Mfg    Dev    Spd
  typedef enum {
    MM_FPGA_XILINX_XC7VX415T_22,  // 0
    MM_FPGA_ALTERA_10AX115_32,    // 1
    MM_FPGA_XILINX_XCVU9P_22L,    // .....
    MM_FPGA_XILINX_XCVU190_22,
    MM_FPGA_XILINX_XCKU095_22,
    MM_FPGA_XILINX_XCVU9P_22I,
    MM_FPGA_XILINX_XCKU060_22,
    MM_FPGA_XILINX_XCVU9P_33,
    MM_FPGA_XILINX_XCVU7P_22,
    MM_FPGA_XILINX_XC7K70T_22,
    MM_FPGA_XILINX_XC7A50T_11,
    MM_FPGA_XILINX_XC7A50T_22,
    MM_FPGA_MICROSEMI_M2GL005,
    MM_FPGA_MICROSEMI_M2GL025T
    } mm_fpga_target_t;

  typedef enum {
    MM_FPGA_7SERIES,
    MM_FPGA_ARRIA10,
    MM_FPGA_ULTRASCALEP,
    MM_FPGA_ULTRASCALE,
    MM_FPGA_IGLOO2
    } mm_fpga_family_t;

  //----------------------------------------------------------------------------
  // Functions
  //----------------------------------------------------------------------------

  function automatic mm_fpga_family_t mm_get_fpga_family (input mm_fpga_target_t fpga_target);
    mm_fpga_family_t fpga_family;

    if (fpga_target == MM_FPGA_XILINX_XCVU7P_22) begin
      fpga_family = MM_FPGA_ULTRASCALEP;
    end else if (fpga_target == MM_FPGA_XILINX_XCVU9P_33) begin
      fpga_family = MM_FPGA_ULTRASCALEP;
    end else if (fpga_target == MM_FPGA_XILINX_XCVU9P_22L) begin
      fpga_family = MM_FPGA_ULTRASCALEP;
    end else if (fpga_target == MM_FPGA_XILINX_XCVU9P_22I) begin
      fpga_family = MM_FPGA_ULTRASCALEP;
    end else if (fpga_target == MM_FPGA_XILINX_XCVU190_22) begin
      fpga_family = MM_FPGA_ULTRASCALE;
    end else if (fpga_target == MM_FPGA_XILINX_XCKU095_22) begin
      fpga_family = MM_FPGA_ULTRASCALE;
    end else if (fpga_target == MM_FPGA_XILINX_XC7VX415T_22) begin
      fpga_family = MM_FPGA_7SERIES;
    end else if (fpga_target == MM_FPGA_XILINX_XC7K70T_22) begin
      fpga_family = MM_FPGA_7SERIES;
    end else if (fpga_target == MM_FPGA_XILINX_XC7A50T_11) begin
      fpga_family = MM_FPGA_7SERIES;
    end else if (fpga_target == MM_FPGA_XILINX_XC7A50T_22) begin
      fpga_family = MM_FPGA_7SERIES;
    end else if (fpga_target == MM_FPGA_ALTERA_10AX115_32) begin
      fpga_family = MM_FPGA_ARRIA10;
    end else if (fpga_target == MM_FPGA_MICROSEMI_M2GL005) begin
      fpga_family = MM_FPGA_IGLOO2;
    end else if (fpga_target == MM_FPGA_MICROSEMI_M2GL025T) begin
      fpga_family = MM_FPGA_IGLOO2;
    end else begin
      $error("Unknown FPGA target specified in mm_get_fpga_family");
    end

    return fpga_family;
  endfunction

endpackage

