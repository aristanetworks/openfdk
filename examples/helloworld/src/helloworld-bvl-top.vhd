--------------------------------------------------------------------------------
-- Copyright (c) 2026 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Maintainers:
--   fdk-support@arista.com
--
-- Description:
--   Helloworld example top module for BVL-series board standards.
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
use work.amba_pkg.all;

use work.yart_pkg.all;
use work.reg_flexi_pkg.all;
use work.reg_file_pkg.all;

--synthesis translate_off
use work.yart_test_pkg.all;
--synthesis translate_on

--------------------------------------------------------------------------------

entity top is
  generic (
    PROJECT_VMAJ_G    : natural          := 0;
    PROJECT_VMIN_G    : natural          := 0;
    PROJECT_VREV_G    : natural          := 0;
    PROJECT_VPRE_G    : natural          := 0;
    PROJECT_NAME_G    : string           := "helloworld";
    PROFILE_NAME_G    : string           := "debug           ";
    I2C_BASE_ADDR_G   : std_logic_vector := 7x"72";

    -- Set the supported PCIe Address Width => 2^22 = 4M Bytes = 1M Registers
    REGISTER_AWIDTH_G : natural := 22;

    -- Simulation Configuration
    SIM_SPEEDUP_G : boolean := false
    );
  port (
    fabric_refclk : in  std_logic_vector(NUM_FABRIC_REFCLKS_C-1 downto 0);

    gt_refclk     : in  diffpair_vector_t(NUM_GT_REFCLKS_C-1 downto 0);
    gt_tx         : out diffpair_vector_t(NUM_GT_PORTS_C downto 1);
    gt_rx         : in  diffpair_vector_t(NUM_GT_PORTS_C downto 1);

    pcie_refclk_p : in  std_logic;
    pcie_refclk_n : in  std_logic;
    pcie_rx_p     : in  std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);
    pcie_rx_n     : in  std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);
    pcie_tx_p     : out std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);
    pcie_tx_n     : out std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);

    app_i2c_in    : in  i2c_type_t;
    app_i2c_out   : out i2c_type_t;

    timesync_clk  : in  std_logic;
    pps_in        : in  std_logic;
    pps_out       : out std_logic := '0';
    sync_in       : in  std_logic;
    sync_out      : out std_logic := '0';
    refclk_out    : out std_logic := '0';

    reserved_in   : in  reserved_in_t;
    reserved_out  : out reserved_out_t := RESERVED_OUT_DFLT_C
    );
end entity top;

--------------------------------------------------------------------------------

architecture rtl of top is

  ------------------------------------------------------------------------------
  -- Constant Declarations
  ------------------------------------------------------------------------------
  constant FPGA_FAMILY_C : mm_fpga_family_t := mm_get_fpga_family(FPGA_TARGET_C);
  constant PS_CLK_FREQ_C : real := 200.0; -- MHz

  ------------------------------------------------------------------------------
  -- Signal Declarations
  ------------------------------------------------------------------------------
  signal ps_clk               : std_logic_vector(3 downto 0);
  signal ps_rst               : std_logic_vector(3 downto 0);
  signal ps_lpd_gpi           : slv32_t := (others => '0');
  signal ps_lpd_gpo           : slv32_t;
  signal pmc_clk              : std_logic_vector(3 downto 0)   := (others => '0');
  signal pmc_mts              : axi4mm_mts_array_t(3 downto 0) := (others => AXI4MM_MTS_DFLT_C);
  signal pmc_stm              : axi4mm_stm_array_t(3 downto 0);

  signal ref_toggle           : std_logic;

  signal mac_baseaddr         : std_logic_vector(47 downto 0);
  signal mac_total            : std_logic_vector(7 downto 0);
  signal bitstream_id         : std_logic_vector(31 downto 0);
  signal platform_id          : std_logic_vector(15 downto 0);
  signal boardstd_id          : std_logic_vector(15 downto 0);
  signal fpga_id              : std_logic_vector(2 downto 0);
  signal device_dna           : std_logic_vector(127 downto 0);

  signal pcie_user_clk        : std_logic;
  signal pcie_user_rst        : std_logic;
  signal pcie_link_up         : std_logic;
  signal pcie_link_speed      : std_logic_vector(2 downto 0);
  signal pcie_link_width      : std_logic_vector(2 downto 0);
  signal pcie_ltssm_state     : std_logic_vector(5 downto 0);
  signal pcie_axis_tx_tready  : std_logic;
  signal pcie_axis_tx_tdata   : std_logic_vector(255 downto 0);
  signal pcie_axis_tx_tkeep   : std_logic_vector(7 downto 0);
  signal pcie_axis_tx_tlast   : std_logic;
  signal pcie_axis_tx_tvalid  : std_logic;
  signal pcie_tx_src_dsc      : std_logic;
  signal pcie_axis_rx_tdata   : std_logic_vector(255 downto 0);
  signal pcie_axis_rx_tkeep   : std_logic_vector(7 downto 0);
  signal pcie_axis_rx_tlast   : std_logic;
  signal pcie_axis_rx_tvalid  : std_logic;
  signal pcie_axis_rx_tready  : std_logic;
  signal pcie_axis_rx_tuser   : std_logic_vector(108 downto 0);
  signal pcie_err_cpl_timeout : std_logic;
  signal pcie_req_compl       : std_logic;
  signal pcie_req_compl_ur    : std_logic;
  signal pcie_compl_done      : std_logic;
  signal m_pl_clk             : std_logic;
  signal m_pl_mts             : axi4mm_mts_t;
  signal m_pl_stm             : axi4mm_stm_t;

  -- Register Interface
  signal reg_addr_vld : std_logic;
  signal reg_addr     : std_logic_vector(15 downto 0);
  signal reg_rdat_vld : std_logic;
  signal reg_rdat     : std_logic_vector(31 downto 0);
  signal reg_wdat_vld : std_logic;
  signal reg_wdat     : std_logic_vector(31 downto 0);

  ------------------------------------------------------------------------------
begin

  --------------------------------------------------------------------------------
  -- Register Interfacing
  --
  i2c_slave_i : entity work.i2c_reg_protocol
    port map (
      clk       => fabric_refclk(0),
      rst       => '0',
      base_addr => I2C_BASE_ADDR_G,

      -- I2C Bus interface
      scl_in    => app_i2c_in.scl,
      scl_low_n => app_i2c_out.scl,
      sda_in    => app_i2c_in.sda,
      sda_low_n => app_i2c_out.sda,

      -- Register Interface
      reg_avld  => reg_addr_vld,
      reg_addr  => reg_addr,
      reg_rvld  => reg_rdat_vld,
      reg_rdata => reg_rdat,
      reg_wvld  => reg_wdat_vld,
      reg_wdata => reg_wdat
      );

  registers_i : entity work.helloworld_registers
    generic map (
      PROJECT_NAME_G => PROJECT_NAME_G
      )
    port map (
      reg_clk   => fabric_refclk(0),
      reg_avld  => reg_addr_vld,
      reg_addr  => reg_addr,
      reg_rvld  => reg_rdat_vld,
      reg_rdata => reg_rdat,
      reg_wvld  => reg_wdat_vld,
      reg_wdata => reg_wdat,

      fpga_id   => fpga_id
      );

  ------------------------------------------------------------------------------
  -- CIPS Module
  ------------------------------------------------------------------------------
  gen_ifn_sim : if not IN_SIMULATION_C generate -- Disable for CSV generation
    u_bvl_cips : entity work.bvl_cips_wrapper
      generic map (
        PCIE_ENABLE_G    => true,
        PCIE_NUM_LANES_G => NUM_PCIE_LANES_C,
        QDMA_ENABLE_G    => false,
        HBM_ENABLE_G     => false
        )
      port map (
        ps_user_clk => ps_clk,
        ps_user_rst => ps_rst,

        ps_lpd_gpi  => ps_lpd_gpi,
        ps_lpd_gpo  => ps_lpd_gpo,

        ------------------------------------------------------------------------
        -- AXI PS-PMC (Subordinate) Interface
        s_pmc_clk => pmc_clk,
        s_pmc_mts => pmc_mts,
        s_pmc_stm => pmc_stm,

        ------------------------------------------------------------------------
        -- PCIe CPM Interfacing
        pcie_refclk_p        => pcie_refclk_p,
        pcie_refclk_n        => pcie_refclk_n,
        pcie_rx_p            => pcie_rx_p,
        pcie_rx_n            => pcie_rx_n,
        pcie_tx_p            => pcie_tx_p,
        pcie_tx_n            => pcie_tx_n,

        pcie_user_clk        => pcie_user_clk, -- 125MHz for GEN3x4; 256MHz for GEN3x8
        pcie_user_rst        => pcie_user_rst,
        pcie_link_up         => pcie_link_up,
        pcie_link_speed      => pcie_link_speed,
        pcie_link_width      => pcie_link_width,
        pcie_ltssm_state     => pcie_ltssm_state,

        pcie_axis_tx_tready  => pcie_axis_tx_tready,
        pcie_axis_tx_tdata   => pcie_axis_tx_tdata,
        pcie_axis_tx_tkeep   => pcie_axis_tx_tkeep,
        pcie_axis_tx_tlast   => pcie_axis_tx_tlast,
        pcie_axis_tx_tvalid  => pcie_axis_tx_tvalid,
        pcie_tx_src_dsc      => pcie_tx_src_dsc,

        pcie_axis_rx_tready  => pcie_axis_rx_tready,
        pcie_axis_rx_tdata   => pcie_axis_rx_tdata,
        pcie_axis_rx_tkeep   => pcie_axis_rx_tkeep,
        pcie_axis_rx_tlast   => pcie_axis_rx_tlast,
        pcie_axis_rx_tvalid  => pcie_axis_rx_tvalid,
        pcie_axis_rx_tuser   => pcie_axis_rx_tuser,

        pcie_err_cpl_timeout => pcie_err_cpl_timeout,
        pcie_req_compl       => pcie_req_compl,
        pcie_req_compl_ur    => pcie_req_compl_ur,
        pcie_compl_done      => pcie_compl_done,

        m_pl_clk             => m_pl_clk,
        m_pl_mts             => m_pl_mts,
        m_pl_stm             => m_pl_stm
        );
  end generate;

  ------------------------------------------------------------------------------
  -- Arista System Controller
  ------------------------------------------------------------------------------
  u_arista_sysctl : entity work.arista_sysctl_v3
    generic map (
      PS_CLK_FREQ_G   => PS_CLK_FREQ_C,
      ENABLE_DEVDNA_G => true
      )
    port map (
      -- Arista Reserved Interface
      reserved_in   => reserved_in,
      reserved_out  => reserved_out,

      -- CIPS Interfacing
      ps_clk        => ps_clk(0),
      ps_rst        => ps_rst(0),
      m_pmc_clk     => pmc_clk(2 downto 0),
      m_pmc_mts     => pmc_mts(2 downto 0),
      m_pmc_stm     => pmc_stm(2 downto 0),

      -- System Configuration Information
      init_dn       => open,         -- Validates following system conifg

      ref_toggle    => ref_toggle,   -- 1s toggle

      mac_baseaddr  => mac_baseaddr, -- Base MAC assigned to this FPGA
      mac_total     => mac_total,    -- Number of MAC assigned to this FPGA
      bitstream_id  => bitstream_id, -- Bitstream ID as programmed into the USERCODE
      platform_id   => platform_id,  -- Platform ID (BVL)
      boardstd_id   => boardstd_id,  -- Board Standard (BVL)
      fpga_id       => fpga_id,      -- Platform FPGA ID (BVL = 0)
      device_dna    => device_dna,   -- Unique (?) FPGA DNA

      hermes_cfg    => open,

      -- System Status Information (Live)
      sysmon_error  => open,
      device_temp   => open,
      psfpd_temp    => open,
      pslpd_temp    => open,
      hbms0_temp    => open,
      hbms1_temp    => open,

      sem_rpu_req   => ps_lpd_gpi(5 downto 0),
      sem_rpu_busy  => ps_lpd_gpo(7)
      );

end architecture rtl;
