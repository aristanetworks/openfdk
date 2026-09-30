--------------------------------------------------------------------------------
-- Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
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

package board_pkg is

  ------------------------------------------------------------------------------
  -- CONSTANT declarations
  constant BOARD_STD_C          : string           := "BVL";
  constant FPGA_TARGET_C        : mm_fpga_target_t := MM_FPGA_XILINX_XCVH1542_33;

  constant NUM_FABRIC_REFCLKS_C : natural := 2;

  constant NUM_GT_REFCLKS_C     : natural := 18;
  constant NUM_GT_PORTS_C       : natural := 68;

  constant NUM_PCIE_LANES_C     : natural := 4;

  constant NUM_GPIO_C           : natural := 16;

  function get_qpll_config (quad : natural) return qpll_cfg_t;
  function get_gt_config (h : natural := NUM_GT_PORTS_C;
                          l : natural := 1) return gt_cfg_t;

  constant GT_CONFIG_C : gt_cfg_t := get_gt_config;

  function get_gt_polarity (gt : integer; dir : string(1 to 2)) return std_logic;

  function get_refclk_idx (clk  : string(1 to 3) := "PRI";
                           quad : natural) return natural;

    -- The CMAC is not currently supported for BVL, but the following constants
    -- and functions must be defined for builds which include the CMAC (even when
    -- genericed out) to compile.
    constant NUM_CMACS_C : natural := 0;
    subtype cmac_idx_t is natural range 0 to NUM_CMACS_C - 1;
    function get_cmac_loc(cmac_idx : cmac_idx_t) return string;
    function get_cmac_gt_port(cmac_idx : cmac_idx_t) return natural;

  -- Signals in reserved_*_t are Arista-internal and may be modified at any time.
  type reserved_in_t is
    record
      fpga_id    : std_logic_vector(2 downto 0);
      system_i2c : i2c_type_t;
      eeprom_i2c : i2c_type_t;
      gpi        : std_logic_vector(NUM_GPIO_C-1 downto 0);
    end record;
  constant RESERVED_IN_DFLT_C : reserved_in_t := (
    fpga_id    => (others => '0'),
    system_i2c => (others => '0'),
    eeprom_i2c => (others => '0'),
    gpi        => (others => '0')
    );

  type reserved_out_t is
    record
      system_i2c   : i2c_type_t;
      eeprom_i2c   : i2c_type_t;
      gpo          : std_logic_vector(NUM_GPIO_C-1 downto 0);
      gpt          : std_logic_vector(NUM_GPIO_C-1 downto 0);
      seu_error    : std_logic;
      sysmon_alert : std_logic;
    end record;
  constant RESERVED_OUT_DFLT_C : reserved_out_t := (
    system_i2c   => (others => '0'),
    eeprom_i2c   => (others => '0'),
    gpo          => (others => '0'),
    gpt          => (others => '0'),
    seu_error    => '0',
    sysmon_alert => '0'
    );

end package board_pkg;

package body board_pkg is

  ------------------------------------------------------------------------------
  -- PLL Reference Clock Configuration Per Quad
  function get_qpll_config (quad : natural) return qpll_cfg_t is
    variable retval : qpll_cfg_t;
  begin
    case quad is
      when 0      => retval.ref0_idx := 0; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 1; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 1      => retval.ref0_idx := 2; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 3; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 2      => retval.ref0_idx := 2; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 3; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 3      => retval.ref0_idx := 4; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 5; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 4      => retval.ref0_idx := 4; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 5; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 5      => retval.ref0_idx := 6; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 7; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 6      => retval.ref0_idx := 6; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 7; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 7      => retval.ref0_idx := 8; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 9; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 8      => retval.ref0_idx := 8; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 9; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 9      => retval.ref0_idx := 10; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 11; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 10     => retval.ref0_idx := 10; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 11; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 11     => retval.ref0_idx := 12; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 13; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 12     => retval.ref0_idx := 12; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 13; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 13     => retval.ref0_idx := 14; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 15; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 14     => retval.ref0_idx := 14; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 15; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 15     => retval.ref0_idx := 16; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 17; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
      when 16     => retval.ref0_idx := 16; retval.ref0_route := "LOCAL"; retval.ref0_sel := "000";
                     retval.ref1_idx := 17; retval.ref1_route := "LOCAL"; retval.ref1_sel := "000";
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

  ------------------------------------------------------------------------------
  -- GT Channel Configuration
  function get_gt_polarity (gt : integer; dir : string(1 to 2)) return std_logic is
  begin
    if dir = "RX" then
      case gt is
        when 21| 22| 23| 24| 54| 56| 57| 58| 60| 61| 63| 65| 67 =>
          return '1';
        when others =>
          return '0';
      end case;
    else -- "TX"
      case gt is
        when 1| 6| 9| 12| 19| 23| 24| 25| 26| 27| 28| 34| 35| 37| 38| 42| 43| 53| 63| 65| 67| 68 =>
          return '1';
        when others =>
          return '0';
      end case;
    end if;
  end get_gt_polarity;

  function get_gt_config (h : natural := NUM_GT_PORTS_C;
                          l : natural := 1) return gt_cfg_t is
    variable ret_val : gt_cfg_t(h downto l);
  begin
    for i in l to h loop
      if i >= 53 then
        ret_val(i).txdiffctrl := 7x"3E"; -- TX Diff Swing (Main Cursor) to 681mV for GTM
      else
        ret_val(i).txdiffctrl := 7x"14"; -- TX Diff Swing to 691mV for GTYP
      end if;
      ret_val(i).txpostcursor := (others => '0');             -- No postcursor
      ret_val(i).txprecursor  := (others => (others => '0')); -- No precursor
      ret_val(i).txpolarity   := get_gt_polarity(i, "TX");
      ret_val(i).txinhibit    := '0';
      ret_val(i).rxinhibit    := '0';
      ret_val(i).rxdfeen      := '0';
      ret_val(i).rxpolarity   := get_gt_polarity(i, "RX");
      ret_val(i).rxreset      := '0';
      ret_val(i).eyescanreset := '0';
    end loop;

    return ret_val;
  end get_gt_config;

  function get_cmac_loc(cmac_idx : cmac_idx_t) return string is
  begin
    assert false
    report "CMAC is not supported on the BVL board"
      severity failure;
    return "FAIL";
  end get_cmac_loc;

  function get_cmac_gt_port(cmac_idx : cmac_idx_t) return natural is
  begin
    assert false
      report "CMAC is not supported on the BVL board"
      severity failure;
    return 1;
  end get_cmac_gt_port;

end package body board_pkg;
