--------------------------------------------------------------------------------
-- Copyright (c) 2017 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Maintainers:
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
    -- Transceiver Recovered Clock Out
    gt_refclk_out_p     : out   std_logic_vector(NUM_GT_REFCLKS_OUT_C-1 downto 0);
    gt_refclk_out_n     : out   std_logic_vector(NUM_GT_REFCLKS_OUT_C-1 downto 0);

    -- Transceivers
    gt_tx_p             : out   std_logic_vector(NUM_GT_PORTS_C downto 1);
    gt_tx_n             : out   std_logic_vector(NUM_GT_PORTS_C downto 1);
    gt_rx_p             : in    std_logic_vector(NUM_GT_PORTS_C downto 1);
    gt_rx_n             : in    std_logic_vector(NUM_GT_PORTS_C downto 1);

    -- Reference Clock Inputs/Outputs
    ts_clk_in           : in    std_logic;
    ts_clk_out          : out   std_logic;

    -- PPS Input/Output
    pps_in_n            : in    std_logic; -- Falling Edge Active PPS pulse
    pps_out             : out   std_logic;

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

    -- Inter-FPGA General Purpose Interfaces
    -- inter_gpa_* connects to LeafA FPGA
    inter_gpa_diff_gc   : inout std_logic_vector(NUM_INTER_GPA_IFS_C*NUM_IGCLK_C-1 downto 0); -- Even P; Odd N; Differential; Global Clock
    inter_gpa_diff      : inout std_logic_vector(NUM_INTER_GPA_IFS_C*NUM_IDIFF_C-1 downto 0); -- Even P; Odd N; Differential
    inter_gpa_gpio      : inout std_logic_vector(NUM_INTER_GPA_IFS_C*NUM_IGPIO_C-1 downto 0); -- Single Ended; Bit (X*3-1) has External PU

    -- inter_gpb_* connects to LeafB FPGA
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

    -- Select MAP Programming interfaces
    leafa_done          : in    std_logic;
    leafa_prog          : out   std_logic;
    leafa_sm_en         : out   std_logic;
    leafa_sm_csi_n      : out   std_logic;
    leafa_sm_rdwr_n     : out   std_logic;
    leafa_sm_cclk       : out   std_logic;
    leafa_sm_data       : out   std_logic_vector(7 downto 0);

    leafb_done          : in    std_logic;
    leafb_prog          : out   std_logic;
    leafb_sm_en         : out   std_logic;
    leafb_sm_csi_n      : out   std_logic;
    leafb_sm_rdwr_n     : out   std_logic;
    leafb_sm_cclk       : out   std_logic;
    leafb_sm_data       : out   std_logic_vector(7 downto 0);

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
  constant EN_SYSCTL_REGS_C : boolean := true;
  constant EN_SYSCTL_SEM_C  : boolean := true;
  constant EN_TEMP_REG_C    : boolean := true;

  ------------------------------------------------------------------------------
  -- Signal Declarations
  ------------------------------------------------------------------------------
  signal emcclk_buf       : std_logic;
  signal emc_clk          : std_logic;

  signal refclk_user_buf  : std_logic_vector(NUM_USER_REFCLKS_C-1 downto 0);
  signal refclk_user      : std_logic_vector(NUM_USER_REFCLKS_C-1 downto 0);
  signal refclk_out       : diffpair_t;

  signal refclk_25        : std_logic;
  signal refclk_25_rst    : std_logic;
  signal refclk_50        : std_logic;
  signal refclk_50_rst    : std_logic;

  signal gt_cfg           : gt_cfg_t(NUM_GT_PORTS_C downto 1);
  signal gt_refclk        : diffpair_vector_t(NUM_GT_REFCLKS_C-1 downto 0);
  signal gt_refclk_out    : diffpair_vector_t(NUM_GT_REFCLKS_OUT_C-1 downto 0);
  signal gt_rx            : diffpair_vector_t(NUM_GT_PORTS_C downto 1);
  signal gt_tx            : diffpair_vector_t(NUM_GT_PORTS_C downto 1);

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
  signal platform_id      : std_logic_vector(15 downto 0);
  signal boardstd_id      : std_logic_vector(15 downto 0);
  signal mac_baseaddr     : std_logic_vector(47 downto 0);
  signal mac_total        : std_logic_vector(7 downto 0);
  signal sysmon_temp      : std_logic_vector(9 downto 0);

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
      refclk_out        => refclk_out,

      pps_in_n          => pps_in_n,
      pps_out           => pps_out,
      ts_clk_in         => ts_clk_in,
      ts_clk_out        => ts_clk_out,

      i2c_scl_in        => i2c_scl_in,
      i2c_scl_out       => i2c_scl_out,
      i2c_sda_in        => i2c_sda_in,
      i2c_sda_out       => i2c_sda_out,
      gpio_in           => gpio_in,
      gpio_out          => gpio_out,
      gpio_tri          => gpio_tri,

      gt_cfg            => gt_cfg,
      gt_refclk         => gt_refclk,
      gt_refclk_out     => gt_refclk_out,
      gt_tx             => gt_tx,
      gt_rx             => gt_rx,
      inter_gt_tx       => open,
      inter_gt_rx       => (others => (others => '0')),
      inter_gt_gpio     => open,

      pcie_root2ep      => pcie_root2ep,
      pcie_ep2root      => pcie_ep2root,

      inter_gpa_diff_gc => inter_gpa_diff_gc,
      inter_gpa_diff    => inter_gpa_diff,
      inter_gpa_gpio    => inter_gpa_gpio,

      inter_gpb_diff_gc => inter_gpb_diff_gc,
      inter_gpb_diff    => inter_gpb_diff,
      inter_gpb_gpio    => inter_gpb_gpio,

      fpga_id           => fpga_id_i,
      platform_id       => platform_id,
      boardstd_id       => boardstd_id,
      mac_baseaddr      => mac_baseaddr,
      mac_total         => mac_total,

      sysmon_temp       => sysmon_temp,

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

  -- refclk_out
  refclk_out_p <= refclk_out.p;
  refclk_out_n <= refclk_out.n;

  -- GT Transceivers
  gen_rc : for i in 0 to NUM_GT_REFCLKS_C-1 generate
    gt_refclk(i).p <= gt_refclk_p(i);
    gt_refclk(i).n <= gt_refclk_n(i);
  end generate;

  gen_rc_out : for i in 0 to NUM_GT_REFCLKS_OUT_C-1 generate
    gt_refclk_out_p(i) <= gt_refclk_out(i).p;
    gt_refclk_out_n(i) <= gt_refclk_out(i).n;
  end generate;

  gen_gt : for i in 1 to NUM_GT_PORTS_C generate
    gt_rx(i).p <= gt_rx_p(i);
    gt_rx(i).n <= gt_rx_n(i);
    gt_tx_p(i) <= gt_tx(i).p;
    gt_tx_n(i) <= gt_tx(i).n;
  end generate;

  -- PCIe
  gen_pcie : for i in 0 to NUM_PCIE_LANES_C-1 generate
    pcie_root2ep.data(i).p <= pcie_rx_p(NUM_PCIE_LANES_C-1-i);
    pcie_root2ep.data(i).n <= pcie_rx_n(NUM_PCIE_LANES_C-1-i);
    pcie_tx_p(i)           <= pcie_ep2root.data(NUM_PCIE_LANES_C-1-i).p;
    pcie_tx_n(i)           <= pcie_ep2root.data(NUM_PCIE_LANES_C-1-i).n;
  end generate;
  pcie_root2ep.perst_n  <= pcie_perst_n;
  pcie_root2ep.refclk.p <= pcie_refclk_p;
  pcie_root2ep.refclk.n <= pcie_refclk_n;
  pcie_wake_n           <= 'Z';



  ------------------------------------------------------------------------------
  -- Select MAP Interface
  ------------------------------------------------------------------------------
  -- FIX ME!!! Connect the selectMAP interface to top and create example design
  -- The Central FPGA has the ability to program the two Leaf FGPAs via the selectMAP interface.
  -- Because this is a semi-custom method, an example design will be created to illustrate
  -- and provide necessary IP.
  ------------------------------------------------------------------------------
  leafa_prog  <= 'Z'; -- External pulldown
  leafa_sm_en <= 'Z'; -- External pulldown
  -- leafa_*  all other selectMAP pins are currently "don't care"

  leafb_prog  <= 'Z'; -- External pulldown
  leafb_sm_en <= 'Z'; -- External pulldown
  -- leafb_*  all other selectMAP pins are currently "don't care"



  ------------------------------------------------------------------------------
  -- Arista System Controller
  ------------------------------------------------------------------------------
  arista_sysctl_i : entity work.arista_sysctl_v2
    generic map (
      FPGA_POSITION_G => FPGA_POSITION_C,

      ENABLE_SYSMON_G => true,
      ENABLE_TEMP_G   => EN_TEMP_REG_C,
      ENABLE_EEPROM_G => false,
      ENABLE_SEM_G    => EN_SYSCTL_SEM_C,
      ENABLE_PHYCFG_G => EN_SYSCTL_REGS_C
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

      mac_baseaddr  => mac_baseaddr,
      mac_total     => mac_total,
      bitstream_id  => top_reserved_in.bitstream_id,
      platform_id   => platform_id,
      boardstd_id   => boardstd_id,
      fpga_id       => fpga_id_i,

      i2c_scl_in    => i2c_scl_in,
      i2c_scl_out   => i2c_scl_out,
      i2c_sda_in    => i2c_sda_in,
      i2c_sda_out   => i2c_sda_out,

      gpio_in       => gpio_in,
      gpio_out      => gpio_out,
      gpio_tri      => gpio_tri,

      eeprom_sts    => top_reserved_in.eeprom_sts,
      sysmon_temp   => sysmon_temp,
      sysmon_alm    => top_reserved_in.sysmon_alm,
      sem_error     => open,
      sem_status    => top_reserved_in.sem_status
      );

end architecture struct;
