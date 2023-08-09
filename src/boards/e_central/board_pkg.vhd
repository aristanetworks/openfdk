--------------------------------------------------------------------------------
-- Copyright (c) 2017-2022 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Author:
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
use work.hermes_pkg.all;
use work.board_common_pkg.all;

package board_pkg is

  ------------------------------------------------------------------------------
  -- CONSTANT declarations
  constant BOARD_STD_C          : string             := "E_CENTRAL";
  constant FPGA_TARGET_C        : mm_fpga_target_t   := MM_FPGA_XILINX_XCKU095_22;
  constant FPGA_POSITION_C      : mm_fpga_position_t := MM_FPGA_POSITION_CENTRAL;

  constant NUM_GT_REFCLKS_C     : natural := 4 + 4;
  constant NUM_GT_REFCLKS_OUT_C : natural := 1;
  constant NUM_GT_PORTS_C       : natural := 24 + 32;
  constant NUM_INTER_GT_PORTS_C : natural := 8;            -- Not Used In Central

  constant NUM_PCIE_LANES_C     : natural := 8;

  constant NUM_USER_REFCLKS_C   : natural := 3;

  constant NUM_INTER_GPA_IFS_C  : natural := 2;
  constant NUM_INTER_GPB_IFS_C  : natural := 2;
  constant NUM_IGCLK_C          : natural := 12;
  constant NUM_IDIFF_C          : natural := 80;
  constant NUM_IGPIO_C          : natural := 6;

  constant NUM_I2C_C            : natural := 2;
  constant NUM_GPIO_C           : natural := 4;

  constant NUM_FLASH_C          : natural := 1;

  function get_gt_config   (h    : natural := NUM_GT_PORTS_C;
                            l    : natural := 1) return gt_cfg_t;

  constant GT_CONFIG_C : gt_cfg_t := get_gt_config;

  function get_refclk_idx (freq : natural;
                           quad : natural) return natural;
  function get_refclk_idx (clk  : string(1 to 3) := "PRI";
                           quad : natural) return natural;

  function get_refclk_out_idx (out_port : natural) return natural;


  -- Signals in top_reserved_in_t are Arista-internal, and may be removed,
  -- changed, or updated, in any new FDK release.
  subtype top_reserved_in_t is top_reserved_in_common_t;
  constant TOP_RESERVED_IN_DFLT_C : top_reserved_in_t := TOP_RESERVED_IN_COMMON_DFLT_C;

  subtype top_reserved_out_t is top_reserved_out_common_t;
  constant TOP_RESERVED_OUT_DFLT_C : top_reserved_out_t := TOP_RESERVED_OUT_COMMON_DFLT_C;

end package board_pkg;

package body board_pkg is

  -- Map Primary or Secondary Clock to Quad IDX
  function get_refclk_idx (clk  : string(1 to 3) := "PRI";
                           quad : natural) return natural is
  begin
    case clk is
      when "PRI"  => return get_refclk_idx(156, quad);
      when "SEC"  => return get_refclk_idx(0, quad);   -- Anything else...
      when others => return 64;  -- invalid, so causes intentional compile error...
    end case;
  end get_refclk_idx;

  function get_refclk_idx (freq : natural;
                           quad : natural) return natural is
    variable clksel : natural := 0;
    variable retval : natural := 0;
  begin
    if freq /= 156 then
      clksel := 1;                      -- default 0
    end if;

    case quad is
      when 0      => retval := 0 + clksel;
      when 1      => retval := 0 + clksel;
      when 2      => retval := 0 + clksel;
      when 3      => retval := 2 + clksel;
      when 4      => retval := 2 + clksel;
      when 5      => retval := 2 + clksel;
      when 6      => retval := 4 + clksel;
      when 7      => retval := 4 + clksel;
      when 8      => retval := 4 + clksel;
      when 9      => retval := 4 + clksel;
      when 10     => retval := 4 + clksel;
      when 11     => retval := 6 + clksel;
      when 12     => retval := 6 + clksel;
      when 13     => retval := 6 + clksel;
      when others => retval := 64;  -- invalid, so causes intentional compile error...
    end case;

    return retval;
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
      if i <= 24 then  -- GTH Transceivers
        ret_val(i).txdiffctrl := "01001"; -- TX Diff Swing to 780mV for GTH
      else             -- GTY Transceivers
        ret_val(i).txdiffctrl := "10000"; -- TX Diff Swing to 780mV for GTY
      end if;
      ret_val(i).txprecursor   := "00000"; -- No precursor
      ret_val(i).txpostcursor  := "00000"; -- No postcursor
      ret_val(i).txpolarity    := '0';
      ret_val(i).txinhibit     := '0';
      ret_val(i).rxdfeen       := '0';
      ret_val(i).rxpolarity    := '0';
      ret_val(i).eyescanreset  := '0';
      ret_val(i).rxreset       := '0';
    end loop;

    return ret_val;
  end get_gt_config;

end package body board_pkg;
