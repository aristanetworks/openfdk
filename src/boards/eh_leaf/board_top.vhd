--------------------------------------------------------------------------------
-- Copyright (c) 2017-2022 Arista Networks, Inc. All rights reserved.
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
    -- Inter-FPGA Transceivers
    inter_gt_tx_p       : out   std_logic_vector(NUM_INTER_GT_PORTS_C downto 1);
    inter_gt_tx_n       : out   std_logic_vector(NUM_INTER_GT_PORTS_C downto 1);
    inter_gt_rx_p       : in    std_logic_vector(NUM_INTER_GT_PORTS_C downto 1);
    inter_gt_rx_n       : in    std_logic_vector(NUM_INTER_GT_PORTS_C downto 1);
    inter_gt_gpio       : inout std_logic;

    -- Reference Clock Inputs/Outputs
    ts_clk_in           : in    std_logic;

    -- PPS Input/Output
    pps_in_n            : in    std_logic; -- Falling Edge Active PPS pulse

    -- User Clocks (From Clock Generator)
    refclk_user_p       : in    std_logic_vector(NUM_USER_REFCLKS_C-1 downto 0);
    refclk_user_n       : in    std_logic_vector(NUM_USER_REFCLKS_C-1 downto 0);

    -- PCIe interface
    pcie_rx_p           : in    std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);
    pcie_rx_n           : in    std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);
    pcie_tx_p           : out   std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);
    pcie_tx_n           : out   std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);

    pcie_wake_n         : out   std_logic;
    pcie_refclk_p       : in    std_logic;
    pcie_refclk_n       : in    std_logic;
    pcie_perst_n        : in    std_logic;

    -- Inter-FPGA General Purpose Interfaces
    -- inter_gpa_* connects to Central FPGA
    inter_gpa_diff_gc   : inout std_logic_vector(NUM_INTER_GPA_IFS_C*NUM_IGCLK_C-1 downto 0); -- Even P; Odd N; Differential; Global Clock
    inter_gpa_diff      : inout std_logic_vector(NUM_INTER_GPA_IFS_C*NUM_IDIFF_C-1 downto 0); -- Even P; Odd N; Differential
    inter_gpa_gpio      : inout std_logic_vector(NUM_INTER_GPA_IFS_C*NUM_IGPIO_C-1 downto 0); -- Single Ended; Bit (X*3-1) has External PU

    -- inter_gpb_* connects to other Leaf FPGA
    inter_gpb_diff_gc   : inout std_logic_vector(NUM_INTER_GPB_IFS_C*NUM_IGCLK_C-1 downto 0); -- Even P; Odd N; Differential; Global Clock
    inter_gpb_diff      : inout std_logic_vector(NUM_INTER_GPB_IFS_C*NUM_IDIFF_C-1 downto 0); -- Even P; Odd N; Differential
    inter_gpb_gpio      : inout std_logic_vector(NUM_INTER_GPB_IFS_C*NUM_IGPIO_C-1 downto 0); -- Single Ended; Bit (X*3-1) has External PU

    -- I2C interface
    i2c_scl             : inout std_logic_vector(NUM_I2C_C-1 downto 0);
    i2c_sda             : inout std_logic_vector(NUM_I2C_C-1 downto 0);

    -- GPIO Interface
    gpio                : inout std_logic_vector(NUM_GPIO_C-1 downto 0);

    -- Flash interface
    -- flash_clk           : out   std_logic;
    -- flash_cs_n          : out   std_logic_vector(NUM_FLASH_C-1 downto 0);
    -- flash_dq            : inout std_logic_vector(NUM_FLASH_C*4-1 downto 0);

    -- System Monitor
    emcclk              : in    std_logic;
    vp                  : in    std_logic;
    vn                  : in    std_logic
    );
end entity board_top;

architecture struct of board_top is

  ------------------------------------------------------------------------------
  -- Local Constants
  ------------------------------------------------------------------------------
  constant DISABLE_SYSCTL_REGS_C : boolean := false;
  constant DISABLE_SYSCTL_SEM_C  : boolean := false;
  CONSTANT ENABLE_TEMP_REG_C     : boolean := true;

  ------------------------------------------------------------------------------
  -- Signal Declarations
  ------------------------------------------------------------------------------
  signal emcclk_buf       : std_logic;
  signal emc_clk          : std_logic;

  signal refclk_user_buf  : std_logic_vector(NUM_USER_REFCLKS_C-1 downto 0);
  signal refclk_user      : std_logic_vector(NUM_USER_REFCLKS_C-1 downto 0);

  signal refclk_25        : std_logic;
  signal refclk_25_rst    : std_logic;
  signal refclk_50        : std_logic;
  signal refclk_50_rst    : std_logic;

  signal gt_cfg           : gt_cfg_t(NUM_GT_PORTS_C downto 1);
  signal gt_refclk        : diffpair_vector_t(NUM_GT_REFCLKS_C-1 downto 0);
  signal gt_rx            : diffpair_vector_t(NUM_GT_PORTS_C downto 1);
  signal gt_tx            : diffpair_vector_t(NUM_GT_PORTS_C downto 1);
  signal inter_gt_rx      : diffpair_vector_t(NUM_INTER_GT_PORTS_C downto 1);
  signal inter_gt_tx      : diffpair_vector_t(NUM_INTER_GT_PORTS_C downto 1);

  signal pcie_root2ep     : pcie_8lane_root2ep_t;
  signal pcie_ep2root     : pcie_8lane_ep2root_t;

  signal i2c_scl_in       : std_logic_vector(NUM_I2C_C-1 downto 1);
  signal i2c_scl_out      : std_logic_vector(NUM_I2C_C-1 downto 1) := (others => '1');
  signal i2c_sda_in       : std_logic_vector(NUM_I2C_C-1 downto 1);
  signal i2c_sda_out      : std_logic_vector(NUM_I2C_C-1 downto 1) := (others => '1');
  signal gpio_in          : std_logic_vector(NUM_GPIO_C-1 downto 0);
  signal gpio_out         : std_logic_vector(NUM_GPIO_C-1 downto 0) := (others => '0');
  signal gpio_tri         : std_logic_vector(NUM_GPIO_C-1 downto 0) := (others => '1');

  signal sem_clock        : std_logic;

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
      emc_clk           => emc_clk,
      refclk_25         => refclk_25,
      refclk_25_rst     => refclk_25_rst,
      refclk_50         => refclk_50,
      refclk_50_rst     => refclk_50_rst,

      refclk_user       => refclk_user,
      refclk_out        => open,

      pps_in_n          => pps_in_n,
      pps_out           => open,
      ts_clk_in         => ts_clk_in,
      ts_clk_out        => open,

      i2c_scl_in        => i2c_scl_in,
      i2c_scl_out       => i2c_scl_out,
      i2c_sda_in        => i2c_sda_in,
      i2c_sda_out       => i2c_sda_out,
      gpio_in           => gpio_in,
      gpio_out          => gpio_out,
      gpio_tri          => gpio_tri,

      gt_cfg            => gt_cfg,
      gt_refclk         => gt_refclk,
      gt_refclk_out     => open,
      gt_tx             => gt_tx,
      gt_rx             => gt_rx,
      inter_gt_tx       => inter_gt_tx,
      inter_gt_rx       => inter_gt_rx,
      inter_gt_gpio     => inter_gt_gpio,

      pcie_root2ep      => pcie_root2ep,
      pcie_ep2root      => pcie_ep2root,

      inter_gpa_diff_gc => inter_gpa_diff_gc,
      inter_gpa_diff    => inter_gpa_diff,
      inter_gpa_gpio    => inter_gpa_gpio,

      inter_gpb_diff_gc => inter_gpb_diff_gc,
      inter_gpb_diff    => inter_gpb_diff,
      inter_gpb_gpio    => inter_gpb_gpio,

      fpga_id           => fpga_id_i,
      sysmon_alm        => sysmon_alm,

      -- Deprecated signals
      fpga_dna          => (others => '0'),
      mac_addr          => (others => (others => '0')),

      -- Reserved signals
      reserved_in       => top_reserved_in,
      reserved_out      => top_reserved_out
      );

  ------------------------------------------------------------------------------
  -- Concurrent Assignments
  ------------------------------------------------------------------------------
  -- EMCCLK (80MHz)
  ibuf_emcclk : IBUF
    port map (
      I => emcclk,
      O => emcclk_buf
      );

  bufg_emcclk : BUFG
    port map (
      I => emcclk_buf,
      O => emc_clk
      );

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
  gen_inter_gt : for i in 1 to NUM_INTER_GT_PORTS_C generate
    inter_gt_rx(i).p <= inter_gt_rx_p(i);
    inter_gt_rx(i).n <= inter_gt_rx_n(i);
    inter_gt_tx_p(i) <= inter_gt_tx(i).p;
    inter_gt_tx_n(i) <= inter_gt_tx(i).n;
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



  ------------------------------------------------------------------------------
  -- Arista System Controller
  ------------------------------------------------------------------------------
  arista_sysctl_i : entity work.arista_sysctl_v2
    generic map (
      FPGA_POSITION_G => FPGA_POSITION_C,

      ENABLE_SYSMON_G => true,
      ENABLE_TEMP_G   => ENABLE_TEMP_REG_C,
      ENABLE_EEPROM_G => false,
      ENABLE_SEM_G    => not DISABLE_SYSCTL_SEM_C,
      ENABLE_PHYCFG_G => not DISABLE_SYSCTL_REGS_C
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

      -- GPIO Interface
      gpio            => gpio,

      -- System Monitor
      vp              => vp,
      vn              => vn,

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
      sem_error     => open,
      sem_status    => top_reserved_in.sem_status
      );

end architecture struct;
