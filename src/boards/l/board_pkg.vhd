--------------------------------------------------------------------------------
-- Copyright (c) 2019 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Maintainers:
--   fdk-support@arista.com
--
-- Description:
--   Package file which describes board-specific constants.
--
--   Licensed under BSD 3-clause license:
--     https://opensource.org/licenses/BSD-3-Clause
--
-- Tags:
--   noencrypt
--   license-bsd-3-clause
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.metamako_pkg.all;
use work.fpga_spec_pkg.all;
use work.phy_pkg.all;
use work.board_common_pkg.all;

package board_pkg is

  ------------------------------------------------------------------------------
  -- CONSTANT declarations
  constant BOARD_STD_C          : string           := "L";
  constant FPGA_TARGET_C        : mm_fpga_target_t := MM_FPGA_XILINX_XCVU7P_22;

  constant NUM_GT_REFCLKS_C     : natural := 24;
  constant NUM_GT_REFCLKS_OUT_C : natural := 1;
  constant NUM_GT_PORTS_C       : natural := 68;

  constant NUM_PCIE_LANES_C     : natural := 8;

  constant NUM_USER_REFCLKS_C   : natural := 2;

  constant NUM_I2C_C            : natural := 7;
  constant NUM_GPIO_C           : natural := 4;

  constant NUM_DIMMS_C          : natural := 4;
  constant NUM_DIMM_DQS_BITS_C  : natural := 9;

  constant NUM_RESERVED_IN_C    : natural := 4;
  constant NUM_RESERVED_OUT_C   : natural := 1;
  constant NUM_RESERVED_INOUT_C : natural := 4;

  function get_qpll_config (quad : natural) return qpll_cfg_t;
  function get_gt_config   (h    : natural := NUM_GT_PORTS_C;
                            l    : natural := 1) return gt_cfg_t;

  constant GT_CONFIG_C : gt_cfg_t := get_gt_config;

  function get_refclk_idx (freq : natural;
                           quad : natural) return natural;
  function get_refclk_idx (clk  : string(1 to 3) := "PRI";
                           quad : natural) return natural;

  function get_refclk_out_idx (out_port : natural) return natural;

  -- Number of CMACE4s supported by this board standard.
  constant NUM_CMACS_C : positive := 3;
  -- Subtype to restrict a user from using out-of-bounds CMAC indexes.
  subtype cmac_idx_t is natural range 0 to NUM_CMACS_C - 1;
  -- Convert a given CMAC index into a string representing the Xilinx XY coordinates, e.g. "X0Y8".
  function get_cmac_loc(cmac_idx : cmac_idx_t) return string;
  -- Retrieve the "master" GT port associated with the quad that is hard-bound
  -- to the CMACE4 which is referenced via the given CMAC index.
  function get_cmac_gt_port(cmac_idx : cmac_idx_t) return positive;

  -- Signals in top_reserved_in_t are Arista-internal, and may be removed,
  -- changed, or updated, in any new FDK release.
  subtype top_reserved_in_t is top_reserved_in_common_t;
  constant TOP_RESERVED_IN_DFLT_C : top_reserved_in_t := TOP_RESERVED_IN_COMMON_DFLT_C;

  subtype top_reserved_out_t is top_reserved_out_common_t;
  constant TOP_RESERVED_OUT_DFLT_C : top_reserved_out_t := TOP_RESERVED_OUT_COMMON_DFLT_C;

end package board_pkg;

package body board_pkg is

  ------------------------------------------------------------------------------
  -- QPLL Reference Clock Configuration Per Quad
  function get_qpll_config (quad : natural) return qpll_cfg_t is
    variable retval : qpll_cfg_t;
  begin
    case quad is
      when 0      => retval.ref0_idx :=  0; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 15; retval.ref1_route := "LOCAL"; retval.ref1_sel := "010";
      when 1      => retval.ref0_idx :=  1; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 15; retval.ref1_route := "NORTH"; retval.ref1_sel := "100";
      when 2      => retval.ref0_idx :=  2; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 16; retval.ref1_route := "LOCAL"; retval.ref1_sel := "010";
      when 3      => retval.ref0_idx :=  3; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 16; retval.ref1_route := "NORTH"; retval.ref1_sel := "100";
      when 4      => retval.ref0_idx :=  4; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 17; retval.ref1_route := "LOCAL"; retval.ref1_sel := "010";
      when 5      => retval.ref0_idx :=  5; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 17; retval.ref1_route := "NORTH"; retval.ref1_sel := "100";
      when 6      => retval.ref0_idx :=  6; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 18; retval.ref1_route := "LOCAL"; retval.ref1_sel := "010";
      when 7      => retval.ref0_idx :=  7; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 19; retval.ref1_route := "SOUTH"; retval.ref1_sel := "110";
      when 8      => retval.ref0_idx :=  8; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 19; retval.ref1_route := "LOCAL"; retval.ref1_sel := "010";
      when 9      => retval.ref0_idx :=  9; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 19; retval.ref1_route := "NORTH"; retval.ref1_sel := "100";
      when 10     => retval.ref0_idx := 10; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 20; retval.ref1_route := "SOUTH"; retval.ref1_sel := "110";
      when 11     => retval.ref0_idx := 11; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 20; retval.ref1_route := "SOUTH"; retval.ref1_sel := "110";
      when 12     => retval.ref0_idx := 12; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 20; retval.ref1_route := "LOCAL"; retval.ref1_sel := "010";
      when 13     => retval.ref0_idx := 13; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 21; retval.ref1_route := "SOUTH"; retval.ref1_sel := "110";
      when 14     => retval.ref0_idx := 14; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 21; retval.ref1_route := "LOCAL"; retval.ref1_sel := "010";
      when 15     => retval.ref0_idx := 22; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 15; retval.ref1_route := "SOUTH"; retval.ref1_sel := "110";
      when 16     => retval.ref0_idx := 23; retval.ref0_route := "LOCAL"; retval.ref0_sel := "001";
                     retval.ref1_idx := 19; retval.ref1_route := "SOUTH"; retval.ref1_sel := "110";
      -- invalid, so causes intentional compile error...
      when others => retval.ref0_idx := 64; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 64; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
    end case;

    return retval;
  end get_qpll_config;

  -- Map Primary or Secondary Clock to Quad IDX
  function get_refclk_idx (clk  : string(1 to 3) := "PRI";
                           quad : natural) return natural is
  begin
    case clk is
      when "PRI"  => return get_qpll_config(quad).ref0_idx;
      when "SEC"  => return get_qpll_config(quad).ref1_idx;
      when others => return 64;  -- invalid, so causes intentional compile error...
    end case;
  end get_refclk_idx;

  function get_refclk_idx (freq : natural;
                           quad : natural) return natural is
  begin
    if freq = 156 then
      return get_qpll_config(quad).ref0_idx;
    else
      return get_qpll_config(quad).ref1_idx;
    end if;
  end get_refclk_idx;

  -- Map clock output to GT Idx number
  function get_refclk_out_idx (out_port : natural) return natural is
    variable retval : natural := 0;
  begin
    case out_port is
      when 0      => retval := 10*4+0; -- Lane 0 of Quad 10
      when others => retval := 64;     -- invalid, so causes intentional compile error...
    end case;
    return retval;
  end get_refclk_out_idx;

  ------------------------------------------------------------------------------
  -- GT Channel Configuration
  function get_gt_config (h : natural := NUM_GT_PORTS_C;
                          l : natural := 1) return gt_cfg_t is
    variable ret_val : gt_cfg_t(h downto l);
  begin
    for i in l to h loop
      ret_val(i).txdiffctrl   := 7x"10";                      -- TX Diff Swing to 780mV for GTY
      ret_val(i).txpostcursor := (others => '0');             -- No postcursor
      ret_val(i).txprecursor  := (others => (others => '0')); -- No precursor
      ret_val(i).txpolarity   := '0';
      ret_val(i).txinhibit    := '0';
      ret_val(i).rxinhibit    := '0';
      ret_val(i).rxdfeen      := '0';
      ret_val(i).rxpolarity   := '0';
      ret_val(i).rxreset      := '0';
      ret_val(i).eyescanreset := '0';
    end loop;
    return ret_val;
  end get_gt_config;

  ------------------------------------------------------------------------------
  -- CMAC physical locations
  function get_cmac_loc(cmac_idx : cmac_idx_t) return string is
  begin
    assert false
      report "CMAC is not supported on the L board"
      severity failure;
    return "FAIL";
  end get_cmac_loc;

  ------------------------------------------------------------------------------
  -- CMAC master port numbers
  function get_cmac_gt_port(cmac_idx : cmac_idx_t) return positive is
  begin
    assert false
      report "CMAC is not supported on the L board"
      severity failure;
    return 1;
  end get_cmac_gt_port;

end package body board_pkg;
