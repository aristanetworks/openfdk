--------------------------------------------------------------------------------
-- Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
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

use work.metamako_pkg.all;
use work.board_pkg.all;
use work.pcie_pkg.all;

entity board_top is
  port (
    -- User Clocks (From Clock Generator)
    fabric_refclk_p : in    std_logic_vector(NUM_FABRIC_REFCLKS_C-1 downto 0);
    fabric_refclk_n : in    std_logic_vector(NUM_FABRIC_REFCLKS_C-1 downto 0);

    -- Transceivers
    gt_refclk_p     : in    std_logic_vector(NUM_GT_REFCLKS_C-1 downto 0);
    gt_refclk_n     : in    std_logic_vector(NUM_GT_REFCLKS_C-1 downto 0);
    gt_tx_p         : out   std_logic_vector(NUM_GT_PORTS_C downto 1);
    gt_tx_n         : out   std_logic_vector(NUM_GT_PORTS_C downto 1);
    gt_rx_p         : in    std_logic_vector(NUM_GT_PORTS_C downto 1);
    gt_rx_n         : in    std_logic_vector(NUM_GT_PORTS_C downto 1);

    -- PCIe interface
    -- pcie_perst_l input on LPD MIO18
    pcie_refclk_p   : in    std_logic;
    pcie_refclk_n   : in    std_logic;
    pcie_rx_p       : in    std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);
    pcie_rx_n       : in    std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);
    pcie_tx_p       : out   std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);
    pcie_tx_n       : out   std_logic_vector(NUM_PCIE_LANES_C-1 downto 0);

    -- I2C interface
    system_scl      : inout std_logic;
    system_sda      : inout std_logic;
    application_scl : inout std_logic;
    application_sda : inout std_logic;
    eeprom_scl      : inout std_logic;
    eeprom_sda      : inout std_logic;

    -- Reference Clock Inputs/Outputs
    timesync_clk_p  : in    std_logic;
    timesync_clk_n  : in    std_logic;

    -- PPS Input/Output
    pps_in          : in    std_logic;
    pps_out         : out   std_logic;

    -- Sync Network Inputs/Outputs
    sync_in_p       : in    std_logic;
    sync_in_n       : in    std_logic;
    sync_out_p      : out   std_logic;
    sync_out_n      : out   std_logic;

    -- Reference Output (To Clock Generator)
    refclk_out_p    : out   std_logic;
    refclk_out_n    : out   std_logic;

    -- FPGA ID
    fpga_id         : in    std_logic_vector(2 downto 0);

    -- GPIO Interface
    gpio            : inout std_logic_vector(NUM_GPIO_C-1 downto 0);

    -- SEU Error Notification to System Controller
    seu_error       : out   std_logic;

    -- Sysmon Alert Notification to System Controller
    sysmon_alert    : out   std_logic
    );
end entity board_top;

architecture struct of board_top is

  ------------------------------------------------------------------------------
  -- Signal Declarations
  ------------------------------------------------------------------------------
  signal fabric_refclk_buf : std_logic_vector(NUM_FABRIC_REFCLKS_C-1 downto 0);
  signal fabric_refclk     : std_logic_vector(NUM_FABRIC_REFCLKS_C-1 downto 0);

  signal gt_refclk         : diffpair_vector_t(NUM_GT_REFCLKS_C-1 downto 0);
  signal gt_rx             : diffpair_vector_t(NUM_GT_PORTS_C downto 1);
  signal gt_tx             : diffpair_vector_t(NUM_GT_PORTS_C downto 1);

  signal application_i2c_i : i2c_type_t;
  signal application_i2c_o : i2c_type_t;

  signal timesync_clk_buf  : std_logic;
  signal timesync_clk      : std_logic;
  signal pps_i             : std_logic;
  signal pps_o             : std_logic;
  signal sync_i            : std_logic;
  signal sync_o            : std_logic;
  signal refclk_o          : std_logic;

  signal reserved_i        : reserved_in_t := RESERVED_IN_DFLT_C;
  signal reserved_o        : reserved_out_t;

begin

  ------------------------------------------------------------------------------
  -- Project Top Instance
  ------------------------------------------------------------------------------
  proj_top_i : entity work.top
    port map (
      fabric_refclk => fabric_refclk,

      gt_refclk     => gt_refclk,
      gt_tx         => gt_tx,
      gt_rx         => gt_rx,

      pcie_refclk_p => pcie_refclk_p,
      pcie_refclk_n => pcie_refclk_n,
      pcie_rx_p     => pcie_rx_p,
      pcie_rx_n     => pcie_rx_n,
      pcie_tx_p     => pcie_tx_p,
      pcie_tx_n     => pcie_tx_n,

      app_i2c_in    => application_i2c_i,
      app_i2c_out   => application_i2c_o,

      timesync_clk  => timesync_clk,
      pps_in        => pps_i,
      pps_out       => pps_o,
      sync_in       => sync_i,
      sync_out      => sync_o,
      refclk_out    => refclk_o,

      reserved_in   => reserved_i,
      reserved_out  => reserved_o
      );

  ------------------------------------------------------------------------------
  -- Continuous Reassignments
  ------------------------------------------------------------------------------

  -- GT Transceivers
  gen_gt_refclk : for i in 0 to NUM_GT_REFCLKS_C-1 generate
    gt_refclk(i).p <= gt_refclk_p(i);
    gt_refclk(i).n <= gt_refclk_n(i);
  end generate;

  gen_gt : for i in 1 to NUM_GT_PORTS_C generate
    gt_rx(i).p <= gt_rx_p(i);
    gt_rx(i).n <= gt_rx_n(i);
    gt_tx_p(i) <= gt_tx(i).p;
    gt_tx_n(i) <= gt_tx(i).n;
  end generate;

  ------------------------------------------------------------------------------
  -- IO Buffers
  ------------------------------------------------------------------------------

  -- Fabric Refclks
  gen_fabric_refclk : for i in 0 to NUM_FABRIC_REFCLKS_C-1 generate
    u_ib_fabric_refclk : IBUFDS
      port map (
        I  => fabric_refclk_p(i),
        IB => fabric_refclk_n(i),
        O  => fabric_refclk_buf(i)
        );

    u_bufg_fabric_refclk : BUFG
      port map (
        I => fabric_refclk_buf(i),
        O => fabric_refclk(i)
        );
  end generate;

  -- I2C
  u_iob_system_scl : IOBUF
    port map (
      O  => reserved_i.system_i2c.scl,
      IO => system_scl,
      I  => '0',
      T  => reserved_o.system_i2c.scl
      );

  u_iob_system_sda : IOBUF
    port map (
      O  => reserved_i.system_i2c.sda,
      IO => system_sda,
      I  => '0',
      T  => reserved_o.system_i2c.sda
      );

  u_iob_app_scl : IOBUF
    port map (
      O  => application_i2c_i.scl,
      IO => application_scl,
      I  => '0',
      T  => application_i2c_o.scl
      );

  u_iob_app_sda : IOBUF
    port map (
      O  => application_i2c_i.sda,
      IO => application_sda,
      I  => '0',
      T  => application_i2c_o.sda
      );

  u_iob_eeprom_scl : IOBUF
    port map (
      O  => reserved_i.eeprom_i2c.scl,
      IO => eeprom_scl,
      I  => '0',
      T  => reserved_o.eeprom_i2c.scl
      );

  u_iob_eeprom_sda : IOBUF
    port map (
      O  => reserved_i.eeprom_i2c.sda,
      IO => eeprom_sda,
      I  => '0',
      T  => reserved_o.eeprom_i2c.sda
      );

  -- Timesync
  u_ib_timesync_clk : IBUFDS
    port map (
      I  => timesync_clk_p,
      IB => timesync_clk_n,
      O  => timesync_clk_buf
      );

  u_bufg_timesync_clk : BUFG
    port map (
      I => timesync_clk_buf,
      O => timesync_clk
      );

  -- PPS
  u_ib_pps_in : IBUF
    port map (
      I => pps_in,
      O => pps_i
      );

  u_ob_pps_out : OBUF
    port map (
      I => pps_o,
      O => pps_out
      );

  -- Sync
  u_ib_sync_in : IBUFDS
    port map (
      I  => sync_in_p,
      IB => sync_in_n,
      O  => sync_i
      );

  u_ob_sync_out : OBUFDS
    port map (
      I  => sync_o,
      O  => sync_out_p,
      OB => sync_out_n
      );

  -- Refclk Output
  u_ob_refclk_out : OBUFDS
    port map (
      I  => refclk_o,
      O  => refclk_out_p,
      OB => refclk_out_n
      );

  -- FPGA ID
  gen_fpga_id : for i in 0 to 2 generate
    u_ib_fpga_id : IBUF
      port map (
        I => fpga_id(i),
        O => reserved_i.fpga_id(i)
        );
  end generate;

  -- GPIO Interface
  gen_gpio : for i in 0 to NUM_GPIO_C-1 generate
    u_iob_gpio : IOBUF
      port map (
        O  => reserved_i.gpi(i),
        IO => gpio(i),
        I  => reserved_o.gpo(i),
        T  => reserved_o.gpt(i)
        );
  end generate;

  -- SEU & Sysmon
  u_ob_seu_error : OBUF
    port map (
      I => reserved_o.seu_error,
      O => seu_error
      );

  u_ob_sysmon_alert : OBUF
    port map (
      I => reserved_o.sysmon_alert,
      O => sysmon_alert
      );

end architecture struct;
