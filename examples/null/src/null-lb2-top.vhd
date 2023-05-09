--------------------------------------------------------------------------------
-- Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Author:
--   fdk-support@arista.com
--
-- Description:
--   Top level module for the Null example running on the L-series board
--   standards.
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
    PROJECT_NAME_G  : string     := "lseries_null    ";
    I2C_BASE_ADDR_G : i2c_addr_t := "1110010";

    -- Simulation Configuration
    SIM_SPEEDUP_G   : boolean    := false -- Set True for Simulation Only!!!
    );
  port (
    refclk_25        : in    std_logic;
    refclk_25_rst    : in    std_logic;
    refclk_50        : in    std_logic;
    refclk_50_rst    : in    std_logic;

    refclk_user      : in    std_logic_vector(NUM_USER_REFCLKS_C-1 downto 0);
    refclk_out       : out   diffpair_t;

    pps_in_n         : in    std_logic;
    pps_out          : out   std_logic;
    ts_clk_in        : in    std_logic;
    ts_diff_clk      : in    diffpair_t;
    ts_clk_out       : out   std_logic;

    sync_in          : in    diffpair_t;
    sync_out         : out   diffpair_t;

    i2c_scl_in       : in    std_logic_vector(NUM_I2C_C-1 downto 1);
    i2c_scl_out      : out   std_logic_vector(NUM_I2C_C-1 downto 1)  := (others => '1');
    i2c_sda_in       : in    std_logic_vector(NUM_I2C_C-1 downto 1);
    i2c_sda_out      : out   std_logic_vector(NUM_I2C_C-1 downto 1)  := (others => '1');
    gpio_in          : in    std_logic_vector(NUM_GPIO_C-1 downto 0);
    gpio_out         : out   std_logic_vector(NUM_GPIO_C-1 downto 0) := (others => '0');
    gpio_tri         : out   std_logic_vector(NUM_GPIO_C-1 downto 0) := (others => '1');

    gt_cfg           : in    gt_cfg_t(NUM_GT_PORTS_C downto 1);
    gt_refclk        : in    diffpair_vector_t(NUM_GT_REFCLKS_C-1 downto 0);
    gt_tx            : out   diffpair_vector_t(NUM_GT_PORTS_C downto 1);
    gt_rx            : in    diffpair_vector_t(NUM_GT_PORTS_C downto 1);

    pcie_root2ep     : in    pcie_8lane_root2ep_t;
    pcie_ep2root     : out   pcie_8lane_ep2root_t;

    ddr4_sysclk      : in    diffpair_vector_t(NUM_DIMMS_C-1 downto 0);
    ddr4_data_strobe : inout ddr4_inout_array_t(NUM_DIMMS_C-1 downto 0);
    ddr4_ctrl        : out   ddr4_host2mem_array_t(NUM_DIMMS_C-1 downto 0);

    fpga_id          : in    std_logic_vector(2 downto 0);

    sysmon_alm       : in    std_logic_vector(15 downto 0);
    crc_error        : out   std_logic := '0';

    -- Signals below are deprecated and disabled,
    -- and will be removed in a future version of the FDK.
    fpga_dna         : in    std_logic_vector(95 downto 0);
    mac_addr         : in    slv48_array_t(NUM_GT_PORTS_C downto 1);

    -- Signals below are reserved and subject to change.
    reserved_in      : in    top_reserved_in_t;
    reserved_out     : out   top_reserved_out_t := TOP_RESERVED_OUT_DFLT_C
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

  obufds_sync_out : OBUFDS
    port map (
      I  => '1',
      O  => sync_out.p,
      OB => sync_out.n
      );

  --------------------------------------------------------------------------------
  -- Unused Tieoffs Signals
  --
  gen_num_ddrs : for i in 0 to NUM_DIMMS_C-1 generate
    ddr4_data_strobe(i).dq <= (others => 'Z');
    ddr4_data_strobe(i).dm <= (others => 'Z');

    ddr4_ctrl(i).addr      <= (others => '0');
    ddr4_ctrl(i).ba        <= (others => '0');
    ddr4_ctrl(i).bg        <= (others => '0');
    ddr4_ctrl(i).reset_n   <= '1';
    ddr4_ctrl(i).cke       <= (others => '0');
    ddr4_ctrl(i).cs_n      <= (others => '1');
    ddr4_ctrl(i).odt       <= (others => '0');
    ddr4_ctrl(i).act_n     <= '1';
    ddr4_ctrl(i).parity    <= '0';

    gen_ck_ties : for j in ddr4_ctrl(i).ck'range generate
      obufds_ddr4_ck : OBUFDS
        port map (
          I  => '0',
          O  => ddr4_ctrl(i).ck(j).p,
          OB => ddr4_ctrl(i).ck(j).n
          );
    end generate;

    gen_strobe_ties : for j in ddr4_data_strobe(i).dqs'range generate
      iobufds_ddr4_dqs : IOBUFDS
        port map (
          IO  => ddr4_data_strobe(i).dqs(j).p,
          IOB => ddr4_data_strobe(i).dqs(j).n,
          I   => '0',
          O   => open,
          T   => '1'
          );
    end generate;

    ibufds_ddr4_sysclk : IBUFDS
      port map (
        I  => ddr4_sysclk(i).p,
        IB => ddr4_sysclk(i).n,
        O  => open
        );
  end generate;

end architecture rtl;

--------------------------------------------------------------------------------
