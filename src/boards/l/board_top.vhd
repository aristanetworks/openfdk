--------------------------------------------------------------------------------
-- Copyright (c) 2019-2022 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Author:
--   fdk-support@arista.com
--
-- Description:
--   This is the board level top VHDL
--   Please refer to the development kit documentation for device specific
--   interface definitions.
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

use work.board_pkg.all;
use work.metamako_pkg.all;
use work.fpga_spec_pkg.all;
use work.pcie_pkg.all;
use work.phy_pkg.all;
use work.hermes_pkg.all;

entity board_top is
  port (
    -- Transceiver Reference Clocks
    gt_refclk_p         : in    std_logic_vector(NUM_GT_REFCLKS_C-1 downto 0);
    gt_refclk_n         : in    std_logic_vector(NUM_GT_REFCLKS_C-1 downto 0);

    -- Transceivers
    gt_tx_p             : out   std_logic_vector(NUM_GT_PORTS_C downto 1);
    gt_tx_n             : out   std_logic_vector(NUM_GT_PORTS_C downto 1);
    gt_rx_p             : in    std_logic_vector(NUM_GT_PORTS_C downto 1);
    gt_rx_n             : in    std_logic_vector(NUM_GT_PORTS_C downto 1);

    -- Reference Clock Inputs/Outputs
    ts_clk_in           : in    std_logic;
    ts_clk_out          : out   std_logic;
    ts_clk_clksel_n     : out   std_logic;
    ts_diff_clk_p       : in    std_logic;
    ts_diff_clk_n       : in    std_logic;

    -- PPS Input/Output
    pps_in_n            : in    std_logic; -- Falling Edge Active PPS pulse
    pps_out             : out   std_logic;

    -- Sync Network Inputs/Outputs
    sync_in_p           : in    std_logic;
    sync_in_n           : in    std_logic;
    sync_out_p          : out   std_logic;
    sync_out_n          : out   std_logic;

    -- User Clocks (From Clock Generator)
    refclk_user_p       : in    std_logic_vector(NUM_USER_REFCLKS_C-1 downto 0);
    refclk_user_n       : in    std_logic_vector(NUM_USER_REFCLKS_C-1 downto 0);

    -- Reference Output (To Clock Generator)
    refclk_out_p        : out   std_logic;
    refclk_out_n        : out   std_logic;

    -- PCIe interface
    pcie_rx_p           : in    std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);
    pcie_rx_n           : in    std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);
    pcie_tx_p           : out   std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);
    pcie_tx_n           : out   std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);

    pcie_wake_n         : out   std_logic;
    pcie_refclk_p       : in    std_logic;
    pcie_refclk_n       : in    std_logic;
    pcie_perst_n        : in    std_logic;

    -- I2C interface
    i2c_scl             : inout std_logic_vector(NUM_I2C_C-1 downto 0);
    i2c_sda             : inout std_logic_vector(NUM_I2C_C-1 downto 0);

    -- GPIO Interface
    gpio                : inout std_logic_vector(NUM_GPIO_C-1 downto 0);

    -- FPGA ID
    fpga_id             : in    std_logic_vector(2 downto 0);

    -- DRAM
    dimm0_sys_clk_p     : in    std_logic;
    dimm0_sys_clk_n     : in    std_logic;
    dimm0_ddr4_adr      : out   std_logic_vector(17 downto 0);
    dimm0_ddr4_ba       : out   std_logic_vector(1 downto 0);
    dimm0_ddr4_cke      : out   std_logic_vector(1 downto 0);
    dimm0_ddr4_cs_n     : out   std_logic_vector(1 downto 0);
    dimm0_ddr4_dm_dbi_n : inout std_logic_vector(8 downto 0);
    dimm0_ddr4_dq       : inout std_logic_vector(71 downto 0);
    dimm0_ddr4_dqs_c    : inout std_logic_vector(8 downto 0);
    dimm0_ddr4_dqs_t    : inout std_logic_vector(8 downto 0);
    dimm0_ddr4_odt      : out   std_logic_vector(1 downto 0);
    dimm0_ddr4_parity   : out   std_logic;
    dimm0_ddr4_bg       : out   std_logic_vector(1 downto 0);
    dimm0_ddr4_reset_n  : out   std_logic;
    dimm0_ddr4_act_n    : out   std_logic;
    dimm0_ddr4_ck_c     : out   std_logic_vector(1 downto 0);
    dimm0_ddr4_ck_t     : out   std_logic_vector(1 downto 0);

    dimm1_sys_clk_p     : in    std_logic;
    dimm1_sys_clk_n     : in    std_logic;
    dimm1_ddr4_adr      : out   std_logic_vector(17 downto 0);
    dimm1_ddr4_ba       : out   std_logic_vector(1 downto 0);
    dimm1_ddr4_cke      : out   std_logic_vector(1 downto 0);
    dimm1_ddr4_cs_n     : out   std_logic_vector(1 downto 0);
    dimm1_ddr4_dm_dbi_n : inout std_logic_vector(8 downto 0);
    dimm1_ddr4_dq       : inout std_logic_vector(71 downto 0);
    dimm1_ddr4_dqs_c    : inout std_logic_vector(8 downto 0);
    dimm1_ddr4_dqs_t    : inout std_logic_vector(8 downto 0);
    dimm1_ddr4_odt      : out   std_logic_vector(1 downto 0);
    dimm1_ddr4_parity   : out   std_logic;
    dimm1_ddr4_bg       : out   std_logic_vector(1 downto 0);
    dimm1_ddr4_reset_n  : out   std_logic;
    dimm1_ddr4_act_n    : out   std_logic;
    dimm1_ddr4_ck_c     : out   std_logic_vector(1 downto 0);
    dimm1_ddr4_ck_t     : out   std_logic_vector(1 downto 0);

    dimm2_sys_clk_p     : in    std_logic;
    dimm2_sys_clk_n     : in    std_logic;
    dimm2_ddr4_adr      : out   std_logic_vector(17 downto 0);
    dimm2_ddr4_ba       : out   std_logic_vector(1 downto 0);
    dimm2_ddr4_cke      : out   std_logic_vector(1 downto 0);
    dimm2_ddr4_cs_n     : out   std_logic_vector(1 downto 0);
    dimm2_ddr4_dm_dbi_n : inout std_logic_vector(8 downto 0);
    dimm2_ddr4_dq       : inout std_logic_vector(71 downto 0);
    dimm2_ddr4_dqs_c    : inout std_logic_vector(8 downto 0);
    dimm2_ddr4_dqs_t    : inout std_logic_vector(8 downto 0);
    dimm2_ddr4_odt      : out   std_logic_vector(1 downto 0);
    dimm2_ddr4_parity   : out   std_logic;
    dimm2_ddr4_bg       : out   std_logic_vector(1 downto 0);
    dimm2_ddr4_reset_n  : out   std_logic;
    dimm2_ddr4_act_n    : out   std_logic;
    dimm2_ddr4_ck_c     : out   std_logic_vector(1 downto 0);
    dimm2_ddr4_ck_t     : out   std_logic_vector(1 downto 0);

    dimm3_sys_clk_p     : in    std_logic;
    dimm3_sys_clk_n     : in    std_logic;
    dimm3_ddr4_adr      : out   std_logic_vector(17 downto 0);
    dimm3_ddr4_ba       : out   std_logic_vector(1 downto 0);
    dimm3_ddr4_cke      : out   std_logic_vector(1 downto 0);
    dimm3_ddr4_cs_n     : out   std_logic_vector(1 downto 0);
    dimm3_ddr4_dm_dbi_n : inout std_logic_vector(8 downto 0);
    dimm3_ddr4_dq       : inout std_logic_vector(71 downto 0);
    dimm3_ddr4_dqs_c    : inout std_logic_vector(8 downto 0);
    dimm3_ddr4_dqs_t    : inout std_logic_vector(8 downto 0);
    dimm3_ddr4_odt      : out   std_logic_vector(1 downto 0);
    dimm3_ddr4_parity   : out   std_logic;
    dimm3_ddr4_bg       : out   std_logic_vector(1 downto 0);
    dimm3_ddr4_reset_n  : out   std_logic;
    dimm3_ddr4_act_n    : out   std_logic;
    dimm3_ddr4_ck_c     : out   std_logic_vector(1 downto 0);
    dimm3_ddr4_ck_t     : out   std_logic_vector(1 downto 0);

    -- SEU Error Notification to System Controller
    crc_error           : out   std_logic;

    -- OCXO DAC
    dac_spi_sclk        : out   std_logic;
    dac_spi_mosi        : out   std_logic;
    dac_cs_n            : out   std_logic;

    -- System Monitor
    vp                  : in    std_logic;
    vn                  : in    std_logic;

    -- Reserved IO
    reserved_in         : in    std_logic_vector(NUM_RESERVED_IN_C-1 downto 0);
    reserved_out        : out   std_logic_vector(NUM_RESERVED_OUT_C-1 downto 0);
    reserved_inout      : inout std_logic_vector(NUM_RESERVED_INOUT_C-1 downto 0)
    );
end entity board_top;

architecture struct of board_top is

  ------------------------------------------------------------------------------
  -- Local Constants
  ------------------------------------------------------------------------------
  constant DISABLE_SYSCTL_REGS_C : boolean := false;
  constant DISABLE_SYSCTL_SEM_C  : boolean := false;
  CONSTANT ENABLE_TEMP_REG_C     : boolean := true;
  constant EN_TEST_LOGIC_C       : boolean := false;
  constant EN_TEST_GPIO_C        : boolean := false;

  ------------------------------------------------------------------------------
  -- Signal Declarations
  ------------------------------------------------------------------------------
  signal refclk_user_buf  : std_logic_vector(NUM_USER_REFCLKS_C-1 downto 0);
  signal refclk_user      : std_logic_vector(NUM_USER_REFCLKS_C-1 downto 0);
  signal refclk_out       : diffpair_t;

  signal sync_in          : diffpair_t;
  signal sync_out         : diffpair_t;
  signal ts_diff_clk      : diffpair_t;

  signal refclk_25        : std_logic;
  signal refclk_25_rst    : std_logic;
  signal refclk_50        : std_logic;
  signal refclk_50_rst    : std_logic;

  signal gt_cfg           : gt_cfg_t(NUM_GT_PORTS_C downto 1);
  signal gt_refclk        : diffpair_vector_t(NUM_GT_REFCLKS_C-1 downto 0);
  signal gt_rx            : diffpair_vector_t(NUM_GT_PORTS_C downto 1);
  signal gt_tx            : diffpair_vector_t(NUM_GT_PORTS_C downto 1);

  signal pcie_root2ep     : pcie_8lane_root2ep_t;
  signal pcie_ep2root     : pcie_8lane_ep2root_t;

  signal ddr4_data_strobe : ddr4_inout_array_t(NUM_DIMMS_C-1 downto 0);
  signal ddr4_ctrl        : ddr4_host2mem_array_t(NUM_DIMMS_C-1 downto 0);
  signal ddr4_sysclk      : diffpair_vector_t(NUM_DIMMS_C-1 downto 0);

  signal i2c_scl_in       : std_logic_vector(NUM_I2C_C-1 downto 1);
  signal i2c_scl_out      : std_logic_vector(NUM_I2C_C-1 downto 1) := (others => '1');
  signal i2c_sda_in       : std_logic_vector(NUM_I2C_C-1 downto 1);
  signal i2c_sda_out      : std_logic_vector(NUM_I2C_C-1 downto 1) := (others => '1');
  signal gpio_in          : std_logic_vector(NUM_GPIO_C-1 downto 0);
  signal gpio_out         : std_logic_vector(NUM_GPIO_C-1 downto 0) := (others => '0');
  signal gpio_tri         : std_logic_vector(NUM_GPIO_C-1 downto 0) := (others => '1');

  signal sem_clock        : std_logic;
  signal usr_crc_error    : std_logic;
  signal sem_error        : std_logic;

  signal fpga_id_i        : std_logic_vector(2 downto 0);
  signal sysmon_alm       : std_logic_vector(15 downto 0);

  signal top_reserved_in  : top_reserved_in_t;
  signal top_reserved_out : top_reserved_out_t := TOP_RESERVED_OUT_DFLT_C;

begin

  ------------------------------------------------------------------------------
  -- Project Top Instance
  ------------------------------------------------------------------------------
  proj_top_i : entity work.top
    port map (
      refclk_25         => refclk_25,
      refclk_25_rst     => refclk_25_rst,
      refclk_50         => refclk_50,
      refclk_50_rst     => refclk_50_rst,

      refclk_user       => refclk_user,
      refclk_out        => refclk_out,

      pps_in_n          => pps_in_n,
      pps_out           => pps_out,
      ts_clk_in         => ts_clk_in,
      ts_diff_clk       => ts_diff_clk,
      ts_clk_out        => ts_clk_out,

      sync_in           => sync_in,
      sync_out          => sync_out,

      i2c_scl_in        => i2c_scl_in,
      i2c_scl_out       => i2c_scl_out,
      i2c_sda_in        => i2c_sda_in,
      i2c_sda_out       => i2c_sda_out,
      gpio_in           => gpio_in,
      gpio_out          => gpio_out,
      gpio_tri          => gpio_tri,

      gt_cfg            => gt_cfg,
      gt_refclk         => gt_refclk,
      gt_tx             => gt_tx,
      gt_rx             => gt_rx,

      pcie_root2ep      => pcie_root2ep,
      pcie_ep2root      => pcie_ep2root,

      ddr4_sysclk       => ddr4_sysclk,
      ddr4_data_strobe  => ddr4_data_strobe,
      ddr4_ctrl         => ddr4_ctrl,

      fpga_id           => fpga_id_i,
      sysmon_alm        => sysmon_alm,

      crc_error         => usr_crc_error,

      -- Deprecated signals
      fpga_dna          => (others => '0'),
      mac_addr          => (others => (others => '0')),

      -- Reserved signals
      reserved_in       => top_reserved_in,
      reserved_out      => top_reserved_out
      );

  crc_error <= usr_crc_error or sem_error;

  ------------------------------------------------------------------------------
  -- Concurrent Assignments
  ------------------------------------------------------------------------------
  -- refclk_user
  gen_rc_user : for i in 0 to NUM_USER_REFCLKS_C-1 generate
    ibufds_refclk_user : IBUFDS
      port map (
        I  => refclk_user_p(i),
        IB => refclk_user_n(i),
        O  => refclk_user_buf(i)
        );

    bufg_refclk_user : BUFG
      port map (
        I => refclk_user_buf(i),
        O => refclk_user(i)
        );
  end generate;

  -- Note : this clock very specifically, does NOT go through a PLL to
  -- minimise configurable logic between pin and SEM.
  bufg_sem_clock : BUFGCE_DIV
    generic map (
      BUFGCE_DIVIDE => 2
      )
    port map (
      CE  => '1',
      CLR => '0',
      I   => refclk_user_buf(0),
      O   => sem_clock
      );

  -- refclk_out
  refclk_out_p <= refclk_out.p;
  refclk_out_n <= refclk_out.n;

  -- ts_diff_clk
  ts_diff_clk.p <= ts_diff_clk_p;
  ts_diff_clk.n <= ts_diff_clk_n;

  -- Sync
  sync_in.p  <= sync_in_p;
  sync_in.n  <= sync_in_n;
  sync_out_p <= sync_out.p;
  sync_out_n <= sync_out.n;

  -- GT Transceivers
  gen_rc : for i in 0 to NUM_GT_REFCLKS_C-1 generate
    gt_refclk(i).p <= gt_refclk_p(i);
    gt_refclk(i).n <= gt_refclk_n(i);
  end generate;

  gen_gt : for i in 1 to NUM_GT_PORTS_C generate
    gt_rx(i).p <= gt_rx_p(i);
    gt_rx(i).n <= gt_rx_n(i);
    gt_tx_p(i) <= gt_tx(i).p;
    gt_tx_n(i) <= gt_tx(i).n;
  end generate;

  -- PCIe
  gen_pcie : for i in 0 to NUM_PCIE_LANES_C-1 generate
    pcie_root2ep.data(i).p <= pcie_rx_p(i);
    pcie_root2ep.data(i).n <= pcie_rx_n(i);
    pcie_tx_p(i)           <= pcie_ep2root.data(i).p;
    pcie_tx_n(i)           <= pcie_ep2root.data(i).n;
  end generate;
  pcie_root2ep.perst_n  <= pcie_perst_n;
  pcie_root2ep.refclk.p <= pcie_refclk_p;
  pcie_root2ep.refclk.n <= pcie_refclk_n;
  pcie_wake_n           <= 'Z';

  -- Map DDR4 signals to records
  ddr4_sysclk(0).p    <= dimm0_sys_clk_p;
  ddr4_sysclk(0).n    <= dimm0_sys_clk_n;
  dimm0_ddr4_adr      <= ddr4_ctrl(0).addr;
  dimm0_ddr4_ba       <= ddr4_ctrl(0).ba;
  dimm0_ddr4_bg       <= ddr4_ctrl(0).bg;
  dimm0_ddr4_ck_c(0)  <= ddr4_ctrl(0).ck(0).n;
  dimm0_ddr4_ck_t(0)  <= ddr4_ctrl(0).ck(0).p;
  dimm0_ddr4_ck_c(1)  <= ddr4_ctrl(0).ck(1).n;
  dimm0_ddr4_ck_t(1)  <= ddr4_ctrl(0).ck(1).p;
  dimm0_ddr4_cke      <= ddr4_ctrl(0).cke;
  dimm0_ddr4_parity   <= ddr4_ctrl(0).parity;
  dimm0_ddr4_act_n    <= ddr4_ctrl(0).act_n;
  dimm0_ddr4_reset_n  <= ddr4_ctrl(0).reset_n;
  dimm0_ddr4_cs_n     <= ddr4_ctrl(0).cs_n(1 downto 0);
  dimm0_ddr4_odt      <= ddr4_ctrl(0).odt;
  dimm0_ddr4_dm_dbi_n <= ddr4_data_strobe(0).dm;
  dimm0_ddr4_dq       <= ddr4_data_strobe(0).dq;
  dqs_0_map : for i in 0 to 8 generate
  begin
    dimm0_ddr4_dqs_c(i) <= ddr4_data_strobe(0).dqs(i).n;
    dimm0_ddr4_dqs_t(i) <= ddr4_data_strobe(0).dqs(i).p;
  end generate;

  ddr4_sysclk(1).p    <= dimm1_sys_clk_p;
  ddr4_sysclk(1).n    <= dimm1_sys_clk_n;
  dimm1_ddr4_adr      <= ddr4_ctrl(1).addr;
  dimm1_ddr4_ba       <= ddr4_ctrl(1).ba;
  dimm1_ddr4_bg       <= ddr4_ctrl(1).bg;
  dimm1_ddr4_ck_c(0)  <= ddr4_ctrl(1).ck(0).n;
  dimm1_ddr4_ck_t(0)  <= ddr4_ctrl(1).ck(0).p;
  dimm1_ddr4_ck_c(1)  <= ddr4_ctrl(1).ck(1).n;
  dimm1_ddr4_ck_t(1)  <= ddr4_ctrl(1).ck(1).p;
  dimm1_ddr4_cke      <= ddr4_ctrl(1).cke;
  dimm1_ddr4_parity   <= ddr4_ctrl(1).parity;
  dimm1_ddr4_act_n    <= ddr4_ctrl(1).act_n;
  dimm1_ddr4_reset_n  <= ddr4_ctrl(1).reset_n;
  dimm1_ddr4_cs_n     <= ddr4_ctrl(1).cs_n(1 downto 0);
  dimm1_ddr4_odt      <= ddr4_ctrl(1).odt;
  dimm1_ddr4_dm_dbi_n <= ddr4_data_strobe(1).dm;
  dimm1_ddr4_dq       <= ddr4_data_strobe(1).dq;
  dqs_1_map : for i in 0 to 8 generate
  begin
    dimm1_ddr4_dqs_c(i) <= ddr4_data_strobe(1).dqs(i).n;
    dimm1_ddr4_dqs_t(i) <= ddr4_data_strobe(1).dqs(i).p;
  end generate;

  ddr4_sysclk(2).p    <= dimm2_sys_clk_p;
  ddr4_sysclk(2).n    <= dimm2_sys_clk_n;
  dimm2_ddr4_adr      <= ddr4_ctrl(2).addr;
  dimm2_ddr4_ba       <= ddr4_ctrl(2).ba;
  dimm2_ddr4_bg       <= ddr4_ctrl(2).bg;
  dimm2_ddr4_ck_c(0)  <= ddr4_ctrl(2).ck(0).n;
  dimm2_ddr4_ck_t(0)  <= ddr4_ctrl(2).ck(0).p;
  dimm2_ddr4_ck_c(1)  <= ddr4_ctrl(2).ck(1).n;
  dimm2_ddr4_ck_t(1)  <= ddr4_ctrl(2).ck(1).p;
  dimm2_ddr4_cke      <= ddr4_ctrl(2).cke;
  dimm2_ddr4_parity   <= ddr4_ctrl(2).parity;
  dimm2_ddr4_act_n    <= ddr4_ctrl(2).act_n;
  dimm2_ddr4_reset_n  <= ddr4_ctrl(2).reset_n;
  dimm2_ddr4_cs_n     <= ddr4_ctrl(2).cs_n(1 downto 0);
  dimm2_ddr4_odt      <= ddr4_ctrl(2).odt;
  dimm2_ddr4_dm_dbi_n <= ddr4_data_strobe(2).dm;
  dimm2_ddr4_dq       <= ddr4_data_strobe(2).dq;
  dqs_2_map : for i in 0 to 8 generate
  begin
    dimm2_ddr4_dqs_c(i) <= ddr4_data_strobe(2).dqs(i).n;
    dimm2_ddr4_dqs_t(i) <= ddr4_data_strobe(2).dqs(i).p;
  end generate;

  ddr4_sysclk(3).p    <= dimm3_sys_clk_p;
  ddr4_sysclk(3).n    <= dimm3_sys_clk_n;
  dimm3_ddr4_adr      <= ddr4_ctrl(3).addr;
  dimm3_ddr4_ba       <= ddr4_ctrl(3).ba;
  dimm3_ddr4_bg       <= ddr4_ctrl(3).bg;
  dimm3_ddr4_ck_c(0)  <= ddr4_ctrl(3).ck(0).n;
  dimm3_ddr4_ck_t(0)  <= ddr4_ctrl(3).ck(0).p;
  dimm3_ddr4_ck_c(1)  <= ddr4_ctrl(3).ck(1).n;
  dimm3_ddr4_ck_t(1)  <= ddr4_ctrl(3).ck(1).p;
  dimm3_ddr4_cke      <= ddr4_ctrl(3).cke;
  dimm3_ddr4_parity   <= ddr4_ctrl(3).parity;
  dimm3_ddr4_act_n    <= ddr4_ctrl(3).act_n;
  dimm3_ddr4_reset_n  <= ddr4_ctrl(3).reset_n;
  dimm3_ddr4_cs_n     <= ddr4_ctrl(3).cs_n(1 downto 0);
  dimm3_ddr4_odt      <= ddr4_ctrl(3).odt;
  dimm3_ddr4_dm_dbi_n <= ddr4_data_strobe(3).dm;
  dimm3_ddr4_dq       <= ddr4_data_strobe(3).dq;
  dqs_3_map : for i in 0 to 8 generate
  begin
    dimm3_ddr4_dqs_c(i) <= ddr4_data_strobe(3).dqs(i).n;
    dimm3_ddr4_dqs_t(i) <= ddr4_data_strobe(3).dqs(i).p;
  end generate;

  ------------------------------------------------------------------------------
  -- Arista System Controller
  ------------------------------------------------------------------------------
  arista_sysctl_i : entity work.arista_sysctl_v2
    generic map (
      ENABLE_SYSMON_G => true,
      ENABLE_TEMP_G   => ENABLE_TEMP_REG_C,
      ENABLE_EEPROM_G => true,
      ENABLE_SEM_G    => not DISABLE_SYSCTL_SEM_C,
      ENABLE_PHYCFG_G => not DISABLE_SYSCTL_REGS_C,

      ENABLE_TEST_LOGIC_G  => EN_TEST_LOGIC_C,
      ENABLE_TEST_GPIO_G   => EN_TEST_GPIO_C,
      NUM_RESERVED_IN_G    => NUM_RESERVED_IN_C,
      NUM_RESERVED_OUT_G   => NUM_RESERVED_OUT_C,
      NUM_RESERVED_INOUT_G => NUM_RESERVED_INOUT_C
      )
    port map (
      --------------------------------------------------------------------------
      -- External Interface
      --------------------------------------------------------------------------
      -- Reference Clock
      refclk_user     => refclk_user,
      sem_clock       => sem_clock,

      -- I2C interface
      i2c_scl         => i2c_scl,
      i2c_sda         => i2c_sda,

      -- GPIO Interface & FPGA ID
      gpio            => gpio,
      fpgaid          => fpga_id,

      -- OCXO DAC
      dac_spi_sclk    => dac_spi_sclk,
      dac_spi_mosi    => dac_spi_mosi,
      dac_cs_n        => dac_cs_n,
      ts_clk_clksel_n => ts_clk_clksel_n,

      -- System Monitor
      vp              => vp,
      vn              => vn,

      -- Reserved IO
      reserved_in     => reserved_in,
      reserved_out    => reserved_out,
      reserved_inout  => reserved_inout,

      --------------------------------------------------------------------------
      -- Fabric Interface
      --------------------------------------------------------------------------
      refclk_25     => refclk_25,
      refclk_25_rst => refclk_25_rst,
      refclk_50     => refclk_50,
      refclk_50_rst => refclk_50_rst,

      gt_cfg        => gt_cfg,
      hermes_cfg    => top_reserved_in.hermes_cfg,

      mac_baseaddr  => top_reserved_in.mac_baseaddr,
      mac_total     => top_reserved_in.mac_total,
      bitstream_id  => top_reserved_in.bitstream_id,
      platform_id   => top_reserved_in.platform_id,
      boardstd_id   => top_reserved_in.boardstd_id,
      fpga_id       => fpga_id_i,

      i2c_scl_in    => i2c_scl_in,
      i2c_scl_out   => i2c_scl_out,
      i2c_sda_in    => i2c_sda_in,
      i2c_sda_out   => i2c_sda_out,

      gpio_in       => gpio_in,
      gpio_out      => gpio_out,
      gpio_tri      => gpio_tri,

      eeprom_sts    => top_reserved_in.eeprom_sts,
      sysmon_temp   => top_reserved_in.sysmon_temp,
      sysmon_alm    => sysmon_alm,
      sem_error     => sem_error,
      sem_status    => top_reserved_in.sem_status
      );

end architecture struct;
