--------------------------------------------------------------------------------
-- Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Maintainers:
--   fdk-support@arista.com
--
-- Description:
--   Top level module for the Null example design on E-series board standards.
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

library UNISIM;
use UNISIM.VCOMPONENTS.all;

use work.metamako_pkg.all;
use work.fpga_spec_pkg.all;
use work.board_pkg.all;
use work.pcie_pkg.all;
use work.phy_pkg.all;

--------------------------------------------------------------------------------

entity top is
  generic (
    PROJECT_NAME_G  : string     := "eseries_null    ";
    I2C_BASE_ADDR_G : i2c_addr_t := "1110010";

    -- Simulation Configuration
    SIM_SPEEDUP_G   : boolean    := false -- Set True for Simulation Only!!!
    );
  port (
    emc_clk           : in    std_logic;
    refclk_25         : in    std_logic;
    refclk_25_rst     : in    std_logic;
    refclk_50         : in    std_logic;
    refclk_50_rst     : in    std_logic;

    refclk_user       : in    std_logic_vector(NUM_USER_REFCLKS_C-1 downto 0);
    refclk_out        : out   diffpair_t;

    pps_in_n          : in    std_logic;
    pps_out           : out   std_logic;
    ts_clk_in         : in    std_logic;
    ts_clk_out        : out   std_logic;

    i2c_scl_in        : in    std_logic_vector(NUM_I2C_C-1 downto 1);
    i2c_scl_out       : out   std_logic_vector(NUM_I2C_C-1 downto 1)  := (others => '1');
    i2c_sda_in        : in    std_logic_vector(NUM_I2C_C-1 downto 1);
    i2c_sda_out       : out   std_logic_vector(NUM_I2C_C-1 downto 1)  := (others => '1');
    gpio_in           : in    std_logic_vector(NUM_GPIO_C-1 downto 0);
    gpio_out          : out   std_logic_vector(NUM_GPIO_C-1 downto 0) := (others => '0');
    gpio_tri          : out   std_logic_vector(NUM_GPIO_C-1 downto 0) := (others => '1');

    gt_cfg            : in    gt_cfg_t(NUM_GT_PORTS_C downto 1);
    gt_refclk         : in    diffpair_vector_t(NUM_GT_REFCLKS_C-1 downto 0);
    gt_refclk_out     : out   diffpair_vector_t(NUM_GT_REFCLKS_OUT_C-1 downto 0);
    gt_tx             : out   diffpair_vector_t(NUM_GT_PORTS_C downto 1);
    gt_rx             : in    diffpair_vector_t(NUM_GT_PORTS_C downto 1);
    inter_gt_tx       : out   diffpair_vector_t(NUM_INTER_GT_PORTS_C downto 1);
    inter_gt_rx       : in    diffpair_vector_t(NUM_INTER_GT_PORTS_C downto 1);
    inter_gt_gpio     : inout std_logic;

    pcie_root2ep      : in    pcie_8lane_root2ep_t;
    pcie_ep2root      : out   pcie_8lane_ep2root_t;

    inter_gpa_diff_gc : inout std_logic_vector(NUM_INTER_GPA_IFS_C*NUM_IGCLK_C-1 downto 0);
    inter_gpa_diff    : inout std_logic_vector(NUM_INTER_GPA_IFS_C*NUM_IDIFF_C-1 downto 0);
    inter_gpa_gpio    : inout std_logic_vector(NUM_INTER_GPA_IFS_C*NUM_IGPIO_C-1 downto 0);

    inter_gpb_diff_gc : inout std_logic_vector(NUM_INTER_GPB_IFS_C*NUM_IGCLK_C-1 downto 0);
    inter_gpb_diff    : inout std_logic_vector(NUM_INTER_GPB_IFS_C*NUM_IDIFF_C-1 downto 0);
    inter_gpb_gpio    : inout std_logic_vector(NUM_INTER_GPB_IFS_C*NUM_IGPIO_C-1 downto 0);

    fpga_id           : in    std_logic_vector(2 downto 0);
    platform_id       : in    std_logic_vector(15 downto 0);
    boardstd_id       : in    std_logic_vector(15 downto 0);
    mac_baseaddr      : in    std_logic_vector(47 downto 0);
    mac_total         : in    std_logic_vector(7 downto 0);

    sysmon_temp       : in    std_logic_vector(9 downto 0);

    -- Signals below are reserved and subject to change.
    reserved_in       : in    top_reserved_in_t;
    reserved_out      : out   top_reserved_out_t := TOP_RESERVED_OUT_DFLT_C
    );
end entity top;

--------------------------------------------------------------------------------

architecture rtl of top is

  --------------------------------------------------------------------------------
  -- Constant Declarations
  --------------------------------------------------------------------------------
  constant FPGA_FAMILY_C : mm_fpga_family_t := mm_get_fpga_family(FPGA_TARGET_C);

  --------------------------------------------------------------------------------
  -- Signal Declarations
  --------------------------------------------------------------------------------
  -- Timing Reference Signals
  signal pps          : std_logic;
  signal pps_n        : std_logic;
  signal ts_clk_buf   : std_logic;
  signal refclk_ts    : std_logic;

  -- Register Interface
  signal reg_addr_vld : std_logic;
  signal reg_addr     : std_logic_vector(15 downto 0);
  signal reg_rdat_vld : std_logic;
  signal reg_rdat     : std_logic_vector(31 downto 0);
  signal reg_wdat_vld : std_logic;
  signal reg_wdat     : std_logic_vector(31 downto 0);

--------------------------------------------------------------------------------

begin

  --------------------------------------------------------------------------------
  -- Register Interfacing
  --
  i2c_slave_i : entity work.i2c_reg_protocol
    port map (
      clk       => refclk_25,
      rst       => refclk_25_rst,
      base_addr => I2C_BASE_ADDR_G,

      -- I2C Bus interface
      scl_in    => i2c_scl_in(1),
      scl_low_n => i2c_scl_out(1),
      sda_in    => i2c_sda_in(1),
      sda_low_n => i2c_sda_out(1),

      -- Register Interface
      reg_avld  => reg_addr_vld,
      reg_addr  => reg_addr,
      reg_rvld  => reg_rdat_vld,
      reg_rdata => reg_rdat,
      reg_wvld  => reg_wdat_vld,
      reg_wdata => reg_wdat
      );

  registers_i : entity work.null_registers
    generic map (
      PROJECT_NAME_G => PROJECT_NAME_G
      )
    port map (
      reg_clk   => refclk_25,
      reg_avld  => reg_addr_vld,
      reg_addr  => reg_addr,
      reg_rvld  => reg_rdat_vld,
      reg_rdata => reg_rdat,
      reg_wvld  => reg_wdat_vld,
      reg_wdata => reg_wdat,

      fpga_id   => fpga_id
      );

  --------------------------------------------------------------------------------
  -- Timing References
  --
  ibuf_pps : IBUF
    port map (
      I => pps_in_n,
      O => pps_n
      );

  pps <= not pps_n;

  obuf_pps : OBUF
    port map (
      I => pps,
      O => pps_out
      );

  ibuf_ts_clk : IBUF
    port map (
      I => ts_clk_in,
      O => ts_clk_buf
      );

  bufg_ts_clk : BUFG
    port map (
      I => ts_clk_buf,
      O => refclk_ts
      );

  obuf_ts_clk : OBUF
    port map (
      I => refclk_ts,
      O => ts_clk_out
      );

  obufds_refclk : OBUFDS
    port map (
      I  => '0',
      O  => refclk_out.p,
      OB => refclk_out.n
      );

  --------------------------------------------------------------------------------
  -- Unused Tieoffs Signals
  --
  process (emc_clk)
    variable gpio_meta : std_logic;
  begin
    if rising_edge(emc_clk) then
      gpio_tri(0) <= gpio_meta;
      gpio_meta   := or_reduce(sysmon_temp);
    end if;
  end process;

end architecture rtl;

--------------------------------------------------------------------------------
